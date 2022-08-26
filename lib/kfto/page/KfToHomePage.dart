import 'dart:collection';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';
import 'dart:math';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/common/DenkuiDialog.dart';
import 'package:denkuitop/common/Logger.dart';
import 'package:denkuitop/common/Os.dart';
import 'package:denkuitop/common/Path.dart';
import 'package:denkuitop/denkui/data/View.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';
import 'package:denkuitop/kfto/data/DenoLibSocketLife.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/kfto/page/KfToNavigator.dart';
import 'package:denkuitop/kfto/page/uiwidgets/TagTextField.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_cef_web/flutter_desktop_cef_web.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
// import 'package:zefyrka/zefyrka.dart';
import 'package:libdeno_plugin/libdeno_plugin.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_desktop_file_manager/flutter_desktop_file_manager.dart';
import 'package:loading/loading.dart';
// ZefyrController _controller = ZefyrController();

Logger logger = Logger("KfToHomeState");

const RIGHT_WIDTH = 1280 * 0.618;
const MAX_HEIGHT = 720.0;
class KfToHomePage extends BaseRemotePage {
  @override
  BaseRemotePageState createState() {
    return KfToHomeState();
  }
}

class KfToHomeState extends BaseRemotePageState {
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

  TextEditingController _currentPathcontroller;
  var containerKey = GlobalKey();

  Widget cefContainer = null;

  Color get dragLineActiveColor {
    return ColorManager.Get("textdarkr");
  }

  Color get dragLineInActiveColor {
    return ColorManager.Get("textr");
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

  // other module
  DenoLibSocketLife denoLibSocketLife = DenoLibSocketLife();

  //cef view
  var web = FlutterDesktopEditor();

  final _flutterDesktopFileManagerPlugin = FlutterDesktopFileManager();

  // other module end

  KfToHomeState() {
    this._currentPathcontroller = TextEditingController();

    this.initWeb();
    initDenoLibSocket();
  }

  void initDenoLibSocket() {
    denoLibSocketLife.handleIpcMessageCallback = (dynamic data) {
      try {
        this.handleIpcMessage(data);
      } catch (err) {
        showCommonSnack(error: err.toString());
      }
    };

    denoLibSocketLife.onConnectedCallback = () {
      this.ipc().invokeNyName({"invokeName": "getConfig"},
          callback: (AsyncIpcData data) {
        var ktoData = KfToDoIpcData.fromAsync(data);
        var basePath = ktoData.data['basePath'];
        if (basePath == null || basePath == ".") {
          initConfigDirectory(ktoData.data);
        } 
        
      });
    };
  }

  void ensureWebViewShow() {
    if (cefContainer == null ) {
      cefContainer = web.generateCefContainer(RIGHT_WIDTH, MAX_HEIGHT);
      web.loadCefContainer();
      web.setUrl("http://localhost:10825/manoco-editor/index.html?home=" +
          DenkuiRunJsPathHelper.GetResourcePaht());
    }
  }

  void initWeb() {
    web.registerFunction("prepareInjectJs", (dynamic data) {
      this.ipc().invokeNyName({"invokeName": "getConfig"},
          callback: (AsyncIpcData data) {
        var ktoData = KfToDoIpcData.fromAsync(data);
        print("getConfig: ${ktoData}");
        if (ktoData.data['editorInjectJsPath'] != null) {
          var editorInjectJsPath = ktoData.data['editorInjectJsPath'];
          var injectJsList = [];
          if (editorInjectJsPath.runtimeType == String) {
            injectJsList.add(editorInjectJsPath.toString());
          } else if (editorInjectJsPath.runtimeType == List) {
            List<dynamic> list = ktoData.data['editorInjectJsPath'] as List<dynamic>;
            for(var x = 0; x < list.length; x++) {
               var path = list[x].toString();
               injectJsList.add(path);
            }
          }
         
          for(var x = 0; x < injectJsList.length ; x++) {
            CommonReadFile(injectJsList[x], func: (({content, path, suc}) {
              print("CommonReadFile ${content} ${path}");
              web.executeJs(content);
              if (!web.needInsertFirst) {
                web.toggleInsertFirst();
                web.tryInsertFirst();
              }
            }));
          }

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

    web.registerFunction("onShowEditor", (dynamic data) {
      var id = data["id"] as String;
      currentFilePath = id;
      _refreshFilePathTextField();
    });
  }

  void initConfigDirectory(dynamic config, { String title}) {
    print("initConfigDirectory");
    
    DenktuiDialog.initContext(context);
    DenktuiDialog.ShowCommonDialog(contentTitle: title == null ? "没有找到文件保存目录，是否选择" : title, options: [
      CommonDialogButtonOption(
          text: "选择目录",
          callback: () async {
            var newPath = await _flutterDesktopFileManagerPlugin.OnSelectFile();

             this.ipc().invokeNyName({"invokeName": "getConfig"},
              callback: (AsyncIpcData data) {
                var ktoData = KfToDoIpcData.fromAsync(data);
                var basePath = ktoData.data['basePath'];
                var editorInjectJsPath = ktoData.data['editorInjectJsPath'];
                config['basePath'] = newPath;
                if (editorInjectJsPath == null) {
                  config['editorInjectJsPath'] = newPath + DirSpelator + "inject.js";
                } else {
                  config['editorInjectJsPath'] = editorInjectJsPath;
                }
                this.ipc()
                    .invokeNyName({"invokeName": "saveConfig", "data": config}, callback: ((data) {
                      _refresh();
                    }));
                web.hide();
                Future.delayed(Duration(seconds: 1)).then((value){
                    web.needInsertFirst = false;
                    web.executeJs("location.reload(false)");
                    web.show();
                  });
            });
          },
          icon: Icons.folder),
      CommonDialogButtonOption(text: "退出", callback: () {}, icon: Icons.error, optionType: 1)
    ]);
  }

  void refreshByData(KfToDoIpcData data) {
    dataTags = [];
    setState(() {
      ensureWebViewShow();
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
    if (data.name == 'initData') {
      refreshByData(data);
    }

    if (data.name == 'system.toast') {
      showSnack(data);
    }
  }

  AsyncIpcClient ipc() {
    return denoLibSocketLife.ipc();
  }

  void _insertIntoEditor(String content, {String editorId}) {
    
    if (cefContainer == null) {
      ensureWebViewShow();
      web.toggleInsertFirst();
    }

    if (editorId == null) {
      editorId = currentFilePath;
    }

    web.insertByContentNId(content, editorId);
    web.needInsertContent = content;
    web.needInsertPath = editorId;
  }

  void _refreshFilePathTextField() {
    if (currentFilePath == null) {
      return;
    }
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
     bkGC = ColorManager.Get("snackbackground");
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
      web.needInsertContent = value;
      web.needInsertPath = map['path'];
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
      {Function({String content, String path, bool suc}) func}) {
    _readFile(path, callback: (AsyncIpcData data) {
      var ktoData = KfToDoIpcData.fromAsync(data);
      print("onPressSingleItemFunc _readFile callback" + ktoData.toString());
      String path = ktoData.data['path'] as String;
      String error = ktoData.data['error'];
      if (error != null) {

        showCommonSnack(error: error);
        return;
      }
      dynamic content = ktoData.data['content'];
      if (content != null) {
        if (content.runtimeType == String) {

          String content = ktoData.data['content'] as String;
          content = content?.replaceAll('\t', '    ');
          func(content: content, path: path, suc:true);
        } else if (content.runtimeType == LinkedHashMap) {
          String name = content['name'];
          showCommonSnack(msg: name);
        }
      } else {
        func(content: '', path: path, suc: true);
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
    web.loadCefContainer();
    print('onPressSingleItemFunc ' + itemData.type);
    // if (itemData.type )
    if (itemData.path.startsWith('http://') ||
        itemData.path.startsWith('https://')) {
      web.executeJs('location.href = "${itemData.path}"');
    } else {
      var homePath = DenkuiRunJsPathHelper.GetResourcePaht();
      var url =
          "http://localhost:10825/manoco-editor/index.html?home=${homePath}";

      ensureWebViewShow();
      web.executeJs(
          'if (!location.href.startsWith("http://localhost")) { location.href =  "${url}"}');

      CommonReadFile(itemData.path, func: ({content, path, suc}) {
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
                            TextStyle(color: ColorManager.Get("textdarkr")),
                        helperText: 'Input a rss url ',
                        enabledBorder: UnderlineInputBorder(
                          borderSide:
                              BorderSide(color: ColorManager.Get("textdarkr")),
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
                  //           TextStyle(color: ColorManager.Get("textdarkr")),
                  //       helperText: 'Input fileName',
                  //       enabledBorder: UnderlineInputBorder(
                  //         borderSide:
                  //             BorderSide(color: ColorManager.Get("textdarkr")),
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  ViewBuilder.BuildMaterialButton("New blog",
                      icon: Icon(
                        Icons.newspaper,
                        color: ColorManager.Get("textdarkr"),
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
                      currentFilePath = path +
                          "/" +
                          DateTime.now().microsecond.toString() +
                          ".md";
                      _refreshFilePathTextField();
                      content = content.replaceFirst("\$\{title\}", "请输入你的标题");
                      content = content.replaceFirst("\$\{tag\}", "第一个标签");
                      _insertIntoEditor(content, editorId: currentFilePath);
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
            textColor: ColorManager.Get("textdarkr"),
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
        children: [Loading(indicator: BallPulseIndicator(), size: 100.0, color: ViewBuilder.RandomColor(),)],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  Card ACard(Widget widget) {
    return Card(clipBehavior: Clip.antiAlias, child: widget, color: ColorManager.Get("cardbackground"),);
  }

  void onDragLineStart(PointerDownEvent event) {
    setState(() {
      dragLineColor = dragLineActiveColor;
    });

    FlutterDesktopCefWeb.allWebViews.forEach((element) { 
      element.hide();
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
      FlutterDesktopCefWeb.allWebViews.forEach((element) { 
        element.show();
      });
      web.loadCefContainer();

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
                  var childViewList = this.buildListItemView(element.name);
                  if (childViewList.length > 0|| true) {

                  return ViewBuilder.BuildSingleTagContainor(element.name,
                      tagData: element, onPressFunc: (String tag) {
                    setState(() {
                      element.isOpen = !element.isOpen;
                    });
                  }, childListItems: childViewList);
                  } else {
                    return null;
                  }
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

    if (searchTagField == null) {
      searchTagField = KfTodoTextField(onChange: (String value) {
        print("KfTodoTextField onChange ${value}");
        setState(() {
          searchKey = value;
        });
      });
    }


    Widget webCView = cefContainer == null ? MaterialButton(
      child: Loading(indicator: BallPulseIndicator(), size: 100.0, color: ViewBuilder.RandomColor()),
      onPressed: () {
        web.generateCefContainer(400, 500);
    web.loadCefContainer();
      },
    ) : cefContainer;
    dragLineColor = ColorManager.Get("textr");
    var childs = [
      new Container(
        width: left_width_real,
        child: ACard(
          Row(
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
          color: ColorManager.Get("cardbackground"),
          child: Column(
            children: [
              new Container(
                height: 60,
                child: Row(
                  children: [
                    ViewBuilder.BuildMaterialButton("", onPressFunc: () {
                      _saveFile();
                    },
                        color: ColorManager.Get("textdarkr"),
                        icon: Icon(
                          Icons.save_as_sharp,
                          color: ColorManager.Get("textdarkr"),
                          size: ViewBuilder.size(2),
                        )),
                    ViewBuilder.BuildMaterialButton("",
                        onPressFunc: () => this.onPressAddNewFunc(),
                        color: ColorManager.Get("textdarkr"),
                        icon: Icon(
                          Icons.edit,
                          color: ColorManager.Get("textdarkr"),
                          size: ViewBuilder.size(2),
                        )),
                    Expanded(
                      child: Container(
                        color: ColorManager.Get("buttonbackground"),
                        margin: EdgeInsets.symmetric(vertical: ViewBuilder.size(1)),
                        child: TextField(
                          controller: _currentPathcontroller,
                          decoration: InputDecoration(
                              fillColor: null,
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              focusColor: Colors.white,
                              // labelText: filePathLabelText,
                              label: Container(
                                margin: EdgeInsets.fromLTRB(0, ViewBuilder.size(3.5), 0, 0),
                                // color: Colors.black,
                                child: Text(filePathLabelText, style: TextStyle(
                                  color: Colors.white
                                ),),
                              ),
                              // labelStyle: TextStyle(
                              //   color: ViewBuilder.RandomDarkColor()r
                              // ),
                              enabled: false,
                              disabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000)
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0x00000000)
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                  color: Color(0x00000000)
                                ),
                              )),
                          onChanged: _onFilePathInputChange),
                      )
                    )
                  ],
                ),
              ),
              webCView
              // Expanded(
              //   key: containerKey,
              //   child: Container(
              //     alignment: Alignment.topLeft,
              //   // child: Text("flexable"),
              //     child: cefContainer == null ? Container(
              //       color: Colors.amberAccent,
              //       width: 400,
              //       height: 400,
              //     ): cefContainer,
              //   ),
              // )
            ],
          ),
        ),
      ))
    ];

    return Scaffold(
      body: new Container(
        color: ColorManager.Get("background"),
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
                   ViewBuilder.BuildInLineMaterialButton("DarkMode",
                      onPressFunc: () {
                        setState(() {
                          ColorManager.instance().isDarkmode = !ColorManager.instance().isDarkmode;
                        });
                        web.executeJs('window.denkGetKey("funcSwitchDarkMode")(${ColorManager.instance().isDarkmode ? 'true' : 'false'})');
                    },
                    color: ColorManager.Get("textdarkr"),
                    icon: Icon(
                        Icons.dark_mode,
                        color: ColorManager.Get("textdarkr"),
                        size: ViewBuilder.size(2),
                      )
                  ),
                  ViewBuilder.BuildInLineMaterialButton("ReloadEditor",
                      onPressFunc: () {
                    web.executeJs("location.reload(false)");
                  },
                      color: ColorManager.Get("textdarkr"),
                      icon: Icon(
                        Icons.refresh,
                        color: ColorManager.Get("textdarkr"),
                        size: ViewBuilder.size(2),
                      )),
                  ViewBuilder.BuildInLineMaterialButton("Reset Save Folder",
                      onPressFunc: () {
                    this.ipc().invokeNyName({"invokeName": "getConfig"},
                        callback: (AsyncIpcData data) {
                      var ktoData = KfToDoIpcData.fromAsync(data);
          
                      initConfigDirectory(ktoData.data, title: '是否重新选择文件目录');
                    });
                  },
                  
                      color: ColorManager.Get("textdarkr"),
                      icon: Icon(
                        Icons.settings,
                        color: ColorManager.Get("textdarkr"),
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
