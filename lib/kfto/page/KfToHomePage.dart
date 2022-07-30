import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:denkuitop/common/Logger.dart';
import 'package:denkuitop/common/Os.dart';
import 'package:denkuitop/common/Path.dart';
import 'package:denkuitop/common/Toast.dart';
import 'package:denkuitop/denkui/child_process/ChildProcess.dart';
import 'package:denkuitop/denkui/data/View.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/kfto/page/TagFlowDelegate.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:denkuitop/native/KeydownManager.dart';
import 'package:denkuitop/native/LibraryLoader.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_cef_web/flutter_desktop_cef_web.dart';
import 'package:native_hotkey/native_hotkey.dart';
import 'package:quill_delta/quill_delta.dart';
// import 'package:zefyrka/zefyrka.dart';
import 'package:libdeno_plugin/libdeno_plugin.dart';
import 'package:path/path.dart' as p;

// ZefyrController _controller = ZefyrController();

Logger logger = Logger("KfToHomeState");

class KfToHomePage extends BaseRemotePage {
  @override
  BaseRemotePageState createState() {
    return KfToHomeState();
  }
}

class DenkuiRunJsPathHelper {
  static String GetResourcePaht() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/denkuitop'));
      var runableJsPath = "${executableDirPath + '/../Resources'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      // throw new Error('not support');
      return '.';
    }

    return '';
  }

  static String GetDenkBundleJsPath() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/denkuitop'));
      var runableJsPath =
          "${executableDirPath + '/../Resources/denkui.bundle.js'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      var executableDirPath = Platform.resolvedExecutable.substring(
          0, Platform.resolvedExecutable.lastIndexOf('denkuitop.exe'));
      var runableJsPath = "${executableDirPath + '.\\denkui.bundle.js'}";
      return runableJsPath;
    }

    return '';
  }

  static String GetPreloadPath() {
    if (Platform.isMacOS) {
      var executableDirPath = Platform.resolvedExecutable
          .substring(0, Platform.resolvedExecutable.lastIndexOf('/denkuitop'));
      var runableJsPath = "${executableDirPath + '/../Resources/preload.js'}";
      return runableJsPath;
    } else if (Platform.isWindows) {
      var executableDirPath = Platform.resolvedExecutable.substring(
          0, Platform.resolvedExecutable.lastIndexOf('denkuitop.exe'));
      var runableJsPath = "${executableDirPath + '.\\preload.js'}";
      return runableJsPath;
    }

    return '';
  }
}

class KfToHomeState extends BaseRemotePageState {
  var isFirstConnect = false;

  ListData data = null;
  List<KfToDoTagData> dataTags = [];
  String searchKey = "";
  List<KfToDoTagData> get searchedTags {
    if (searchKey == "") {
      return dataTags;
    } else {
      List<KfToDoTagData> searchRes = [];

      for (KfToDoTagData item in dataTags) {
        if (item.name.contains(searchKey)) {
          searchRes.add(item);
        }
      }
      return searchRes;
    }
  }

  String currentFilePath = '';
  String filePathLabelText = 'File Path';
  String currentTag = 'All';
  TextEditingController _currentPathcontroller;

  bool isShowTagDialog = false;

  var highLightColor = const Color(0xFF6200EE);

  LibraryLoader lib;

  Libdeno libdeno = Libdeno();

  //cef view
  var web = FlutterDesktopEditor();

  var containerKey = GlobalKey();

  Widget cefContainor = null;

  KfToHomeState() {
    var port = 8082;

    // TODO make sure port is not be used

    this.lib = LibraryLoader.instance;
    var runableJsPath = DenkuiRunJsPathHelper.GetDenkBundleJsPath();
    print("${runableJsPath}");
    var isDev = false;
    // if (isDev) {
    //   port = 10825;
    // } else {
    // this.lib.libMain("deno run -A ${runableJsPath} --port=${port}");
    libdeno.load();
    libdeno.run("deno run -A ${runableJsPath} --port=${port}");
    // }

    super.init(client: new AsyncIpcClient(), port: port);
    this.ipc().setCallback("onmessage", (String message) async {
      // print(message);
      handleIpcMessage(KfToDoIpcData.raw(message));
    });
    this._currentPathcontroller = TextEditingController();

    NativeHotkey.instance.init();
    // NativeHotkey.instance.setHotkeyListener('ctrl-s', () {
    //   print("callback keyevent ctrl-s");
    //   this._saveFile();
    // });
  }

  void handleIpcMessage(KfToDoIpcData data) {
    if (!isFirstConnect) {
      this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
      isFirstConnect = true;
    }
    if (data.name == 'initData') {
      setState(() {
        this.data = ListData.fromMap(data.data as Map<String, dynamic>);
        this.data?.data?.forEach((element) {
          element.tags.forEach((tag) {
            var tagData = KfToDoTagData(tag);
            var hasTag = false;
            for (KfToDoTagData item in dataTags) {
              if (item.name == tag) {
                hasTag = true;
                break;
              }
            }

            if (!hasTag) {
              dataTags.add(tagData);
            }
          });
        });
        // TODO:
        dataTags.sort((left, right) => left.name.compareTo(right.name));
      });
    }
    if (data.name == 'notifyRead') {
      String readPath = data.data;
      ListItemData listItemData =
          this.data?.data?.where((element) => element.path == readPath).first;
      if (listItemData != null) {
        this.onPressSingleItemFunc(listItemData);
      }
    }

    if (data.name == 'system.toast') {
      showSnack(data);
    }
  }

  @override
  AsyncIpcClient ipc() {
    return super.ipc() as AsyncIpcClient;
  }

  void _clearEditor() {
    setState(() {
      // var document = NotusDocument();
      // _controller = ZefyrController(document);
      // _controller.formatText(0, 1, NotusAttribute.block.code);
    });
  }

  void _insertIntoEditor(String content) {
    web.executeJs(
        "window.denkGetKey('editor').setValue(decodeURIComponent(\"${Uri.encodeComponent(content)}\"))");
    ;
    web.getEditorContent();
  }

  void _refreshFilePathTextField() {
    setState(() {
      _currentPathcontroller.text = GetFileNameFromPath(currentFilePath);
      _currentPathcontroller.selection = TextSelection.fromPosition(
          TextPosition(offset: _currentPathcontroller.text.length));
      filePathLabelText = GetDirFromPath(currentFilePath);
    });
  }

  void _onFilePathInputChange(String value) {
    if (!value.endsWith(DirSpelator) && value.contains(DirSpelator)) {
      currentFilePath = GetDirFromPath(currentFilePath) + DirSpelator + value;
      _refreshFilePathTextField();
    }
    if (value == '') {
      currentFilePath = currentFilePath.substring(
          0, currentFilePath.lastIndexOf(DirSpelator));
      _refreshFilePathTextField();
    }
  }

  void showSnack(AsyncIpcData data) {
    print("raw ${data.raw}");
    print("rawMap ${data.rawMap}");
    String msg = data.rawMap['msg'];
    Color bkGC = null;
    if (msg == null) {
      msg = data.rawMap['data']['msg'];
    }
    if (msg == null) {
      String error = data.rawMap['data']['error'];
      if (error != null) {
        msg = error;
        bkGC = Color(0xffffbcd4);
      }
    }
    print("msg ${msg}");
    print("bkGC ${bkGC}");
    if (msg == null) {
      msg = "ERRRRRRRRRRRRRRR";
    }
    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      backgroundColor: bkGC,
      content: Text(msg),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _saveFile() async {
    var map = Map<String, dynamic>();
    map['path'] = GetDirFromPath(currentFilePath) +
        DirSpelator +
        _currentPathcontroller.text;
    map['content'] = await web.getEditorContent();
    var omap = Map<String, dynamic>();

    omap['data'] = map;
    omap['invokeName'] = 'writeFile';
    this.ipc().invoke(KfToDoIpcData.from("invoke", omap),
        callback: (AsyncIpcData data) {
      showSnack(data);
      _refresh();
    });
  }

  void _refresh() {
    this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
  }

  void _readFile(String path, {AsyncIpcCallback callback = null}) {
    var map = new Map<String, dynamic>();
    map['invokeName'] = 'readFile';
    map['data'] = path;
    this.ipc().invoke(KfToDoIpcData.from('invoke', map), callback: callback);
  }

  void onPressSingleItemFunc(ListItemData itemData) {
    // web.loadCefContainer();
    _readFile(itemData.path, callback: (AsyncIpcData data) {
      print("onPressSingleItemFunc _readFile callback" + data.toString());
      var ktoData = KfToDoIpcData.fromAsync(data);
      String content = ktoData.data['content'] as String;
      String path = ktoData.data['path'] as String;
      currentFilePath = path;
      content = content.replaceAll('\t', '    ');
      _refreshFilePathTextField();
      _insertIntoEditor(content);
    });
  }

  void onLongPressSingleItemFunc(ListItemData itemData) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Container(
              child: buildDeleteButtonItem(itemData, context),
              height: 100,
              alignment: Alignment.center,
            ),
          );
        });
  }

  Widget buildSingleListItem(ListItemData itemData) {
    var backColor = currentFilePath == itemData.path
        ? Colors.black.withOpacity(0.6)
        : Colors.white;
    var forColor = currentFilePath == itemData.path
        ? Colors.white
        : Colors.black.withOpacity(0.6);
    return FlatButton(
      textColor: this.highLightColor,
      onPressed: () {
        this.onPressSingleItemFunc(itemData);
      },
      onLongPress: () {
        this.onLongPressSingleItemFunc(itemData);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backColor,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.arrow_drop_down_sharp, color: forColor),
              title:
                  Text('${itemData.title}', style: TextStyle(color: forColor)),
              subtitle: Text(
                '${itemData.date}\n${GetFileNameFromPath(itemData.path)}',
                style: TextStyle(color: forColor),
              ),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void onPressAddNewFunc() {
    var map = new Map();
    map['invokeName'] = "getNewBlogTemplate";
    this.ipc()?.invoke(KfToDoIpcData.from("invoke", map),
        callback: (AsyncIpcData data) {
      var ktoData = KfToDoIpcData.fromAsync(data);
      String content = ktoData.data['content'] as String;
      String path = ktoData.data['path'] as String;
      currentFilePath = path;
      _refreshFilePathTextField();
      _insertIntoEditor(content);
    });
  }

  void onPressDeleteFunc(ListItemData itemData) {
    handleRemoveThis(itemData);
  }

  Widget buildAddNewButtonItem() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          MaterialButton(
            textColor: this.highLightColor,
            onPressed: () {
              this.onPressAddNewFunc();
            },
            child: const Text('New'),
          )
        ],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  Widget buildDeleteButtonItem(ListItemData itemData, BuildContext context) {
    return MaterialButton(
      textColor: this.highLightColor,
      onPressed: () {
        Navigator.of(context).pop();
        this.onPressDeleteFunc(itemData);
      },
      child: const Text('Remove This'),
    );
  }

  Widget buildLoadingItem() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [Text('LOADING')],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  Card ACard(Widget widget) {
    return Card(clipBehavior: Clip.antiAlias, child: widget);
  }

  List<Widget> buildListItemView(String tag) {
    List<Widget> res = [];
    this.data.data.where((element) => element.tags.contains(tag)).forEach((e) {
      res.add(ViewBuilder.BuildSingleTagListItemContainor(e,
          onPressFunc: (ListItemData e) => this.onPressSingleItemFunc(e),
          onLongPressFunc: (ListItemData e) =>
              this.onLongPressSingleItemFunc(e)));
    });
    return res;
  }

  Widget buildListView() {
    List<Widget> list = [];
    if (this.data?.data != null) {
      dataTags.forEach((element) {
        list.add(ViewBuilder.BuildSingleTagContainor(element.name,
            tagData: element, onPressFunc: (String tag) {
          setState(() {
            element.isOpen = !element.isOpen;
          });
        }, childListItems: this.buildListItemView(element.name)));
      });
    } else {
      list.add(buildLoadingItem());
    }

    return Column(
      children: [
        ViewBuilder.BuildSearchMaterialInput(onChange: (value) {
          // print("search value:" + value + dataTags.toString());
          setState(() {
            searchKey = value;
          });
        }),
        ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 750, minHeight: 56.0),
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if (this.searchedTags.length == 0) {
                    return buildLoadingItem();
                  } else {
                    var element = this.searchedTags[index];
                    return ViewBuilder.BuildSingleTagContainor(element.name,
                        tagData: element, onPressFunc: (String tag) {
                      setState(() {
                        element.isOpen = !element.isOpen;
                      });
                    }, childListItems: this.buildListItemView(element.name));
                  }
                },
                itemCount:
                    this.data?.data != null ? this.searchedTags.length : 1))
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const MAX_WIDTH = 1280 - 25;
    const RIGHT_WIDTH = 1280 * 0.618;
    const LEFT_WIDTH = MAX_WIDTH - RIGHT_WIDTH;
    const MAX_HEIGHT = 720.0;
    const LEFT_TOOLBAR_HEIGHT = 50.0;
    const LEFT_LIST_HEIGHT = MAX_HEIGHT - LEFT_TOOLBAR_HEIGHT;
    // _controller.formatText(0, 1, NotusAttribute.block.code);

    // if (!File('../denkui').existsSync()) {
    //   ChildProcess(ChildProcess.PRE_PARE_DENKUI).run();
    // }
    if (cefContainor == null) {
      cefContainor = web.generateCefContainer(RIGHT_WIDTH, MAX_HEIGHT);
      // var urlPath =p.toUri("file:///Users/chenxiaofang/Desktop/wor/kf/monaco-editor/samples/browser-script-editor/index.html");
      // print('urlPath'+urlPath);
      web.setUrl("http://localhost:10825/manoco-editor/index.html?home=" +
          DenkuiRunJsPathHelper.GetResourcePaht());
      _readFile(DenkuiRunJsPathHelper.GetPreloadPath(),
          callback: (AsyncIpcData data) {
        var ktoData = KfToDoIpcData.fromAsync(data);
        String content = ktoData.data['content'] as String;
        String path = ktoData.data['path'] as String;
        web.executeJs(content);
      });
    }
    web.loadCefContainer();
    var childs = [
      new Container(
        width: LEFT_WIDTH,
        color: Colors.white10,
        child: ACard(Stack(
          children: [
            buildListView(),
          ],
        )),
      ),
      new Container(
          // width: RIGHT_WIDTH,
          key: containerKey,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Container(
                child: Column(children: [
              // ZefyrToolbar.basic(controller: _controller),
              Row(
                children: [
                  Card(
                    child: Container(
                        width: RIGHT_WIDTH * 0.618,
                        child: TextField(
                          controller: _currentPathcontroller,
                          decoration: InputDecoration(
                              fillColor: this.highLightColor,
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              focusColor: this.highLightColor,
                              labelText: filePathLabelText,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: this.highLightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                          onChanged: _onFilePathInputChange,
                        )),
                    margin: const EdgeInsets.all(4),
                  ),
                  ViewBuilder.BuildMaterialButton("Save", onPressFunc: () {
                    _saveFile();
                  },
                      color: this.highLightColor,
                      icon: Icon(
                        Icons.save_as_sharp,
                        color: this.highLightColor,
                        size: ViewBuilder.size(2),
                      )),
                  ViewBuilder.BuildMaterialButton("New",
                      onPressFunc: () => this.onPressAddNewFunc(),
                      color: this.highLightColor,
                      icon: Icon(
                        Icons.add,
                        color: this.highLightColor,
                        size: ViewBuilder.size(2),
                      ))
                ],
              ),
              // Expanded(
              //   child: ZefyrEditor(
              //     controller: _controller,
              //   ),
              // ),
              // !Platform.isMacOS ?
              // MaterialButton(
              //   onPressed: () {
              //     web.showDevtools();
              //   },
              //   child: Text("devtools"),
              // ) : null,

              Expanded(
                child: cefContainor,
              )
            ])),
          ))
    ];

    return Scaffold(
      body: new Container(
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: childs,
        ),
        margin: const EdgeInsets.fromLTRB(0, 30, 0, 60),
      ),
    );
  }

  void handleRemoveThis(ListItemData itemData) {
    var map = Map<String, dynamic>();
    map['path'] = itemData.path;
    var omap = Map<String, dynamic>();

    omap['data'] = map;
    omap['invokeName'] = 'deleteItem';
    this.ipc().invoke(KfToDoIpcData.from("invoke", omap),
        callback: (AsyncIpcData data) {
      _refresh();
    });
  }

  Widget _buildSingleTagView(String text) {
    var backColor =
        currentTag == text ? Colors.black.withOpacity(0.6) : Colors.white;
    var forColor =
        currentTag == text ? Colors.white : Colors.black.withOpacity(0.6);
    return Container(
      height: 50,
      padding: EdgeInsets.all(8),
      child: FlatButton(
          onPressed: (() {
            setState(() {
              isShowTagDialog = !isShowTagDialog;
              currentTag = text;
            });
          }),
          textColor: this.highLightColor,
          color: backColor,
          child: Text(
            text,
            style: TextStyle(color: forColor),
          )),
    );
  }

  List<Widget> buildTagsViews() {
    var res = <Widget>[];

    res.add(_buildSingleTagView("All"));
    var tags = <String>[];
    this.data?.data?.forEach((element) {
      element.tags.forEach((tag) {
        if (!tags.contains(tag)) {
          tags.add(tag);
          res.add(_buildSingleTagView(tag));
        }
      });
    });
    return res;
  }
}
