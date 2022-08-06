import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/common/DenkuiDialog.dart';
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
import 'package:denkuitop/kfto/page/uiwidgets/TagTextField.dart';
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
      List<String> searchKeyItems = [];
      if (searchKey.contains(",")) {
        searchKeyItems = searchKey.split(",");
      } else {
        searchKeyItems = [searchKey];
      }

      searchKeyItems.forEach((element) {
        for (KfToDoTagData item in dataTags) {
          if (item.name.contains(element) && !searchRes.contains(item)) {
            searchRes.add(item);
          }
        }
      });
      return searchRes;
    }
  }

  String currentFilePath = '';
  String filePathLabelText = 'File Path';
  String currentTag = 'All';
  TextEditingController _currentPathcontroller;

  bool isShowTagDialog = false;

  LibraryLoader lib;

  Libdeno libdeno = Libdeno();

  //cef view
  var web = FlutterDesktopEditor();

  var containerKey = GlobalKey();

  Widget cefContainor = null;

  Color get dragLineActiveColor {
    return ColorManager.highLightColor;
  }

  Color get dragLineInActiveColor {
    return Colors.amberAccent;
  }

  Color dragLineColor = Colors.amberAccent;

  bool isDragingLine = false;

  double left_width_real = 300;

  double left_width_drag_start = 0;
  Offset left_widnth_drag_start_pos = Offset.zero;

  String dialog_editor_rss_url = "";

  String dialog_editor_blog_file_name = "";
  bool isWriteWithoutRead = false;

  KfTodoTextField searchTagField;

  KfToHomeState() {
    var port = 8082;

    // TODO make sure port is not be used

    this.lib = LibraryLoader.instance;
    var runableJsPath = DenkuiRunJsPathHelper.GetDenkBundleJsPath();
    print("${runableJsPath}");
    var isDevDeno = false;
    if (isDevDeno) {
      port = 8082;
    } else {
      libdeno.load();
      libdeno.run("deno run -A ${runableJsPath} --port=${port}");
    }

    super.init(client: new AsyncIpcClient(), port: port);
    this.ipc().setCallback("onmessage", (String message) async {
      // print(message);
      handleIpcMessage(KfToDoIpcData.raw(message));
    });
    this._currentPathcontroller = TextEditingController();

    NativeHotkey.instance.init();

    web.registerFunction("prepareInjectJs", (dynamic data) {
      this.ipc().invokeNyName({"invokeName": "getConfig"},
          callback: (AsyncIpcData data) {
        var ktoData = KfToDoIpcData.fromAsync(data);
        print("getConfig: ${ktoData}");
        if (ktoData.data['editorInjectJsPath'] != null) {
          var path = ktoData.data['editorInjectJsPath'].toString();
          CommonReadFile(path, func: (({content, path}) {
            web.executeJs(content);
          }));
        }
      });
    });

    web.registerFunction("onEditorCreate", (dynamic data) {
      ListItemData listItemData = this
          .data
          ?.data
          ?.where((element) => element.path == currentFilePath)
          ?.first;
      if (listItemData != null) {
        this.onPressSingleItemFunc(listItemData);
      }
    });

    web.registerFunction("editorSave", (dynamic data) {
      _saveFile();
    });

  }

  void refreshByData(KfToDoIpcData data) {
    setState(() {
      this.data = ListData.fromMap(data.data as Map<String, dynamic>);

      this.data?.data?.forEach((element) {
        element.tags.forEach((tag) {
          var tagData = KfToDoTagData(tag);
          if (element.type == 'rss') {
            tagData.isRss = true;
          }
          if (element.type == 'rssItem') {
            tagData.isRssItem = true;
          }
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
      dataTags.sort((left, right) => left.name.compareTo(right.name));
    });
  }

  void handleIpcMessage(KfToDoIpcData data) {
    if (!isFirstConnect) {
      this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
      isFirstConnect = true;
    }
    if (data.name == 'initData') {
      refreshByData(data);
    }
    // if (data.name == 'notifyRead') {
    //   if (isWriteWithoutRead) {
    //     isWriteWithoutRead = false;
    //     return;
    //   }
    //   String readPath = data.data;
    //   ListItemData listItemData =
    //       this.data?.data?.where((element) => element.path == readPath)?.first;
    //   if (listItemData != null) {
    //     print("onPressSingleItemFunc from notifyRead");
    //     this.onPressSingleItemFunc(listItemData);
    //   }
    // }

    if (data.name == 'system.toast') {
      showSnack(data);
    }
  }

  @override
  AsyncIpcClient ipc() {
    return super.ipc() as AsyncIpcClient;
  }

  void _clearEditor() {}

  void _insertIntoEditor(String content, {String editorId}) {
    if (editorId == null) {
      editorId = currentFilePath;
    }
    web.executeJs(
        'window.denkGetKey("insertIntoEditor")(decodeURIComponent(\"${Uri.encodeComponent(content)}\"), "${editorId}")');
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

  void showCommonSnack({String msg, String error}) {
    Color bkGC = null;
    if (error != null) {
      msg = error;
      bkGC = Color(0xffffbcd4);
    }
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

  void showSnack(AsyncIpcData data) {
    // print("raw ${data.raw}");
    // print("rawMap ${data.rawMap}");
    String msg = data.rawMap['msg'];
    if (msg == null) {
      msg = data.rawMap['data']['msg'];
    }
    showCommonSnack(msg: msg, error: data.rawMap['data']['error']);
  }

  void _saveFile() async {
    print('_saveFile ${currentFilePath}');
    var map = Map<String, dynamic>();
    map['path'] = GetDirFromPath(currentFilePath) +
        DirSpelator +
        _currentPathcontroller.text;

    web.getEditorContent(currentFilePath).then((value) {
      map['content'] = value;
      var omap = Map<String, dynamic>();

      omap['data'] = map;
      omap['invokeName'] = 'writeFile';
      this.ipc().invoke(KfToDoIpcData.from("invoke", omap),
          callback: (AsyncIpcData data) {
        showSnack(data);
        _refresh();
      });
    }).catchError((err) {
      showCommonSnack(msg: null, error: err.toString());
    });
  }

  void _refresh() {
    this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
  }

  void CommonReadFile(String path,
      {Function({String content, String path}) func}) {
    _readFile(path, callback: (AsyncIpcData data) {
      print("onPressSingleItemFunc _readFile callback" + data.toString());
      var ktoData = KfToDoIpcData.fromAsync(data);
      String path = ktoData.data['path'] as String;
      if (ktoData.data['content'] != null) {
        String content = ktoData.data['content'] as String;
        content = content.replaceAll('\t', '    ');
        func(content: content, path: path);
      } else {
        func(content: '', path: path);
      }
    });
  }

  void _readFile(String path, {AsyncIpcCallback callback = null}) {
    var map = new Map<String, dynamic>();
    map['invokeName'] = 'readFile';
    map['data'] = path;
    this.ipc().invoke(KfToDoIpcData.from('invoke', map), callback: callback);
  }

  void onPressSingleItemFunc(ListItemData itemData) {
    // web.loadCefContainer();
    print('onPressSingleItemFunc ' + itemData.type);
    // if (itemData.type )
    if (itemData.path.startsWith('http://') ||
        itemData.path.startsWith('https://')) {
      web.executeJs('location.href = "${itemData.path}"');
    } else {
      var homePath = DenkuiRunJsPathHelper.GetResourcePaht();
      var url =
          "http://localhost:10825/manoco-editor/index.html?home=${homePath}";

      web.executeJs(
          'if (!location.href.startsWith("http://localhost")) { location.href =  "${url}"}');
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
  }

  void onLongPressSingleItemFunc(ListItemData itemData) {
    DenktuiDialog.initContext(context);
    DenktuiDialog.ShowCommonDialog(contentTitle: "Delete this item", options: [
      CommonDialogButtonOption(
          text: "Delete",
          callback: () {
            this.onPressDeleteFunc(itemData);
          },
          icon: Icons.delete),
      CommonDialogButtonOption(
          text: "Cancel", callback: () {}, icon: Icons.cancel)
    ]);
  }

  void onPressAddNewFunc() {
    DenktuiDialog.initContext(context);
    DenktuiDialog.ShowDialog(
        content: Container(
          width: 500,
          height: 500,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ACard(Container(
                child: Column(children: [
                  ListTile(
                    leading: Icon(Icons.rss_feed),
                    title: const Text('RSS'),
                    subtitle: Text(
                      'Add a rss ',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: TextFormField(
                      cursorColor: Theme.of(context).cursorColor,
                      initialValue: 'http://',
                      onChanged: (String value) {
                        this.dialog_editor_rss_url = value;
                      },
                      decoration: InputDecoration(
                        labelText: 'RSS url',
                        labelStyle:
                            TextStyle(color: ColorManager.highLightColor),
                        helperText: 'Input a rss url ',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorManager.highLightColor),
                        ),
                      ),
                    ),
                  ),
                  ViewBuilder.BuildMaterialButton("Add to List",
                      onPressFunc: () {
                    Navigator.pop(context);
                    this.ipc().invokeNyName({
                      "invokeName": "addRss",
                      "data": {"url": this.dialog_editor_rss_url}
                    }, callback: (AsyncIpcData data) {
                      showSnack(data);
                      refreshByData(KfToDoIpcData.fromAsync(data));
                    });
                  })
                ]),
              )),
              ACard(Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.text_format),
                    title: const Text('Text'),
                    subtitle: Text(
                      'Add a text ',
                      style: TextStyle(color: Colors.black.withOpacity(0.6)),
                    ),
                  ),
                  // Container(
                  //   margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
                  //   child: TextFormField(
                  //     cursorColor: Theme.of(context).cursorColor,
                  //     initialValue: '',
                  //     onChanged: (String value) {
                  //       this.dialog_editor_blog_file_name = value;
                  //     },
                  //     decoration: InputDecoration(
                  //       labelText: 'File Name',
                  //       labelStyle:
                  //           TextStyle(color: ColorManager.highLightColor),
                  //       helperText: 'Input fileName',
                  //       enabledBorder: UnderlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: ColorManager.highLightColor),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ViewBuilder.BuildMaterialButton("New blog",
                      icon: Icon(
                        Icons.newspaper,
                        color: ColorManager.highLightColor,
                        size: ViewBuilder.size(2),
                      ), onPressFunc: () {
                    Navigator.pop(context);
                    var map = new Map();
                    map['invokeName'] = "getNewBlogTemplate";
                    this.ipc()?.invoke(KfToDoIpcData.from("invoke", map),
                        callback: (AsyncIpcData data) {
                      var ktoData = KfToDoIpcData.fromAsync(data);
                      String content = ktoData.data['content'] as String;
                      String path = ktoData.data['path'] as String;
                      currentFilePath = path + "/" + DateTime.now().microsecond.toString() + ".md";
                      _refreshFilePathTextField();
                      _insertIntoEditor(content, editorId: currentFilePath );
                      isWriteWithoutRead = true;
                    });
                  })
                ],
              ))
            ],
          ),
        ),
        children: []);
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
            textColor: ColorManager.highLightColor,
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

  void onDragLineStart(PointerDownEvent event) {
    setState(() {
      dragLineColor = dragLineActiveColor;
    });
    left_width_drag_start = left_width_real;
    left_widnth_drag_start_pos = event.position;
    isDragingLine = true;
  }

  void onDragLineMoving(PointerMoveEvent event) {
    if (isDragingLine) {
      double dx = event.position.dx - left_widnth_drag_start_pos.dx;
      setState(() {
        left_width_real = left_width_drag_start + dx;
      });
    }
  }

  void onDragLineEnd() {
    setState(() {
      dragLineColor = dragLineInActiveColor;
    });
    isDragingLine = false;
  }

  List<Widget> buildListItemView(String tag) {
    List<Widget> res = [];
    this.data.data.where((element) => element.tags.contains(tag)).forEach((e) {
      res.add(
        ViewBuilder.BuildSingleTagListItemContainor(e,
            rssRefreshFunc: () {
              this.ipc().invokeNyName({
                "invokeName": "addRss",
                "data": {"url": e.path}
              }, callback: (AsyncIpcData data) {
                showSnack(data);

                refreshByData(KfToDoIpcData.fromAsync(data));
              });
            },
            onPressFunc: (ListItemData e) => this.onPressSingleItemFunc(e),
            onLongPressFunc: (ListItemData e) =>
                this.onLongPressSingleItemFunc(e)),
      );
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
        searchTagField.view(),
        // ViewBuilder.BuildSearchMaterialInput(onChange: (value) {
        //   // print("search value:" + value + dataTags.toString());
        //   setState(() {
        //     searchKey = value;
        //   });
        // }, currentSearchKey:  searchKey),
        Expanded(
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
                  this.data?.data != null ? this.searchedTags.length : 1),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const RIGHT_WIDTH = 1280 * 0.618;
    const MAX_HEIGHT = 720.0;

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

    if ( searchTagField == null) {

    searchTagField = KfTodoTextField(onChange: (String value) {
      setState(() {
        searchKey = value;
      });
    });
    }
    web.loadCefContainer();
    var childs = [
      new Container(
        width: left_width_real,
        child: ACard(Row(
          children: [
            Expanded(child: buildListView()),
            Listener(
                onPointerDown: (event) => {onDragLineStart(event)},
                onPointerUp: ((event) => {onDragLineEnd()}),
                onPointerMove: ((event) {
                  onDragLineMoving(event);
                }),
                child: Container(
                    color: dragLineColor,
                    width: 4,
                    height: double.infinity,
                    alignment: Alignment.center,
                    child: Container(
                      width: 2,
                      height: 20,
                      color: Colors.blueGrey,
                    ))),
          ],
        )),
      ),
      Expanded(
          child: Container(
        child: Card(
          // clipBehavior: Clip.antiAlias,
          color: Colors.white,
          child: Column(
            children: [
              new Container(
                height: 60,
                child: Row(
                  children: [
                    ViewBuilder.BuildMaterialButton("", onPressFunc: () {
                      _saveFile();
                    },
                        color: ColorManager.highLightColor,
                        icon: Icon(
                          Icons.save_as_sharp,
                          color: ColorManager.highLightColor,
                          size: ViewBuilder.size(2),
                        )),
                    ViewBuilder.BuildMaterialButton("",
                        onPressFunc: () => this.onPressAddNewFunc(),
                        color: ColorManager.highLightColor,
                        icon: Icon(
                          Icons.edit,
                          color: ColorManager.highLightColor,
                          size: ViewBuilder.size(2),
                        )),
                    Expanded(
                      child: TextField(
                          controller: _currentPathcontroller,
                          decoration: InputDecoration(
                              fillColor: ColorManager.highLightColor,
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              focusColor: ColorManager.highLightColor,
                              labelText: filePathLabelText,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: ColorManager.highLightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
                          onChanged: _onFilePathInputChange),
                    )
                  ],
                ),
              ),
              Expanded(
                key: containerKey,
                child: Container(
                  alignment: Alignment.topLeft,
                  child: cefContainor,
                ),
              )
            ],
          ),
        ),
      ))
    ];

    return Scaffold(
      body: new Container(
        color: Color(0xefefefef),
        child: Column(
          children: [
            Expanded(
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: childs,
              ),
            ),
            Container(
              height: 50,
              width: double.infinity,
              color: Colors.white12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ViewBuilder.BuildInLineMaterialButton("ReloadEditor",
                      onPressFunc: () {
                    web.executeJs("location.reload(false)");
                  },
                      color: ColorManager.highLightColor,
                      icon: Icon(
                        Icons.refresh,
                        color: ColorManager.highLightColor,
                        size: ViewBuilder.size(2),
                      )),
                ],
              ),
            )
          ],
        ),
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
}
