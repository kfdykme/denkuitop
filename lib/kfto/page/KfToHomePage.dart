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
import 'package:denkuitop/common/TextK.dart';
import 'package:denkuitop/denkui/child_process/ChildProcess.dart';
import 'package:denkuitop/denkui/data/View.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';
import 'package:denkuitop/kfto/data/DenoLibSocketLife.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/kfto/page/KfToNavigator.dart';
import 'package:denkuitop/kfto/page/uiwidgets/TagTextField.dart';
import 'package:denkuitop/kfto/page/view/GridCardPainter.dart';
import 'package:denkuitop/kfto/page/view/TreeCardPainter.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:denkuitop/kfto/views/editor/EditorUtils.dart';
import 'package:denkuitop/native/DenoManager.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:denkuitop/utils/NetworkUtils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_desktop_cef_web/cef_widget.dart';
import 'package:flutter_desktop_cef_web/flutter_desktop_cef_web.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
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
          var name = item.name.toLowerCase();
          element = element.toLowerCase();
          if (name.contains(element) && !searchRes.contains(item)) {
            searchRes.add(item);
          }
        }
      });
      return searchRes;
    }
  }

  List<ListItemData> get searchedListData {
    List<ListItemData> items = [];
    searchedTags.forEach((tag) {
      var searcedItems =
          this.data.data.where((element) => element.tags.contains(tag.name));
      items.addAll(searcedItems);
    });
    return items;
  }

  String currentFilePath = '';
  String filePathLabelText = '';

  TextEditingController _currentPathcontroller;

  var treeCardPainterKey = GlobalKey();


  Color get dragLineActiveColor {
    return ColorManager.Get("textdarkr");
  }

  Color get dragLineInActiveColor {
    return ColorManager.Get("textr");
  }

  bool isDragingLine = false;

  double left_width_real = 300;

  double left_width_drag_start = 0;
  Offset left_widnth_drag_start_pos = Offset.zero;

  String dialog_editor_rss_url = "";

  String dialog_editor_blog_file_name = "";
  bool isWriteWithoutRead = false;

  bool is_darging_tree_card = false;
  Offset darging_tree_card_pos = Offset.zero;
  Offset tree_card_mouse_pos = Offset.zero;
  Offset darging_tree_card_pos_cache = Offset.zero;

  KfTodoTextField searchTagField;

  TreeCardData treeCardData = null;

  double currentWindowHeight = 650;

  // other module
  DenoLibSocketLife denoLibSocketLife = DenoLibSocketLife();

  //cef view
  FlutterDesktopEditor web;
  CefWidget cefWidget;


  final _flutterDesktopFileManagerPlugin = FlutterDesktopFileManager();

  // other module end

  bool isTreeCardMode = false;

  // Feature 101 文件本地历史记录 START

  bool isReadingLocalHistory = false;

  List<Object> localHistoryDatas = [];

  // Feature 101 文件本地历史记录 END

  // Snack Text
  String snackText = '';
  Color snackColor = Colors.amber;
  List<String> snackTextList = [];
  int snackIndex = 0;


  // dialog
  String dialogCurrentFocus = 'markdown';

  // injectJsFinished
  bool injectJsFinished = false;

  KfToHomeState() {
    this._currentPathcontroller = TextEditingController();

    web = FlutterDesktopEditor();
    cefWidget=  CefWidget(url: getDefaultUrl(), web: web,);
    web.titleHeight = 0;
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
            print("onConnected");
        var ktoData = KfToDoIpcData.fromAsync(data);
        var basePath = ktoData.data['basePath'];
        if (basePath == null || basePath == ".") {
          initConfigDirectory(ktoData.data, isCanQuit: true);
        }

        initWeb();
      });
    };
    
  }

  void initWeb() {
    print("initWeb");
    web.registerFunction("prepareInjectJs", (dynamic data) {
      print("on prepareInjectJs event");
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
            List<dynamic> list =
                ktoData.data['editorInjectJsPath'] as List<dynamic>;
            for (var x = 0; x < list.length; x++) {
              var path = list[x].toString();
              injectJsList.add(path);
            }
          }

          web.show();
          // if (!kDebugMode) {
            for (var x = 0; x < injectJsList.length; x++) {
              CommonReadFile(injectJsList[x], func: (({content, path, suc}) {
                print("CommonReadFile path: ${path}");
                web.executeJs(content);
                if (!web.needInsertFirst) {
                  web.toggleInsertFirst();
                  web.tryInsertFirst();
                }
              }));
            }
          // }

          // MARK: injectJs finish
          injectJsFinished = true;
          print("on prepareInjectJs event success");
        } else if (ktoData.data['basePath'] == "." || ktoData.data['basePath'] == null) {
          initConfigDirectory(ktoData.data, isCanQuit: true);
        } else {
          print("ipcError");
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

    web.registerFunction("insertImageFromClipboard", (dynamic data) {
      print("insertImageFromClipboard ${data}");
      String fileName = data["fileName"] as String;
      _flutterDesktopFileManagerPlugin.tryWriteImageFromClipboard(fileName)
      .then((value) {
        print("tryWriteImageFromClipboard result value ${value}");
        web.executeJs("window.denkGetKey('insertMarkdownImage')('${value}')");
      });
    });

    web.registerFunction("onShowEditor", (dynamic data) {
      var id = data["id"] as String;
      currentFilePath = id;
      _refreshFilePathTextField();
    });

    web.registerFunction("openLink", (dynamic data) {
      var url = data["url"] as String;
      if (url.startsWith("#")) {
        var target = url.substring(1);
        // find
        ListItemData listItemData =
            this.data?.data?.where((element) => element.path == target)?.first;
        if (listItemData != null) {
          this.onPressSingleItemFunc(listItemData);
        }
      } else {
        ChildProcess(ChildProcessArg.from("open ${url}")).run();
      }
    });

    web.registerFunctionWithResult('getUrlTitle', (dynamic data) {
      print("getUrlTitle ${data}");
      var url = data["url"] as String;
      return NetworkUtils().getTitleFromUrl(url);
    });
  }

  void initConfigDirectory(dynamic config, {String title, bool isCanQuit = false}) {
    print("initConfigDirectory");

    DenktuiDialog.initContext(context);
    DenktuiDialog.ShowCommonDialog(
        contentTitle: title == null ? TextK.Get("没有找到文件保存目录，是否选择文件夹") : title,
        options: [
          CommonDialogButtonOption(
              text: TextK.Get("选择目录"),
              callback: () async {
                var newPath =
                    await _flutterDesktopFileManagerPlugin.OnSelectFile();
                if (newPath != "") {

                  this.ipc().invokeNyName({"invokeName": "getConfig"},
                      callback: (AsyncIpcData data) {
                    config['basePath'] = newPath;
                    config['isDarkmode'] = ColorManager.instance().isDarkmode;
                    config["resourcePath"] =
                        DenkuiRunJsPathHelper.GetResourcePath();
                    this.ipc().invokeNyName(
                        {"invokeName": "saveConfig", "data": config},
                        callback: ((data) {
                      _refresh();
                    }));
                    web.hide();
                    Future.delayed(Duration(seconds: 1)).then((value) {
                      web.needInsertFirst = false;
                      web.executeJs("location.reload(false)");
                      web.show();
                    });
                  });
                } else {
                  initConfigDirectory(config, title: title, isCanQuit: isCanQuit);
                }
              },
              icon: Icons.folder),
          CommonDialogButtonOption(
              text: isCanQuit ? TextK.Get("退出") : TextK.Get("取消"),
              callback: () {
                if (isCanQuit) {
                  exit(-200);
                } 
              },
              icon: Icons.error,
              optionType: 1)
        ], barrierDismissible: false);
  }

  void refreshByData(KfToDoIpcData data) {
    logger.log("refreshByData");
    dataTags = [];
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

          if (kReleaseMode &&
              (tagData.name == "_KfTodoConfig" ||
                  tagData.name == "_DENKUISCRIPT")) {
            hasTag = true;
          }

          if (!hasTag) {
            dataTags.add(tagData);
          }
        });
      });
      dataTags.sort((left, right) => left.name.compareTo(right.name));
      logger.log("refreshByData setState end");
    
    });
  }

  void handleIpcMessage(KfToDoIpcData data) {
    if (data.name == 'initData') {
      refreshByData(data);
      return;
    }


    if (data.name == 'system.toast') {
      showSnack(data);
      return;
    }

    // 会导致新文件保存的时候有问题
    // if (data.name == 'notifyRead') {
    //   String lastPath = data.rawMap["data"];
    //   print("notifyRead ${lastPath}");
    //   ListItemData item =  this.data.data.firstWhere((element) {
    //     return element.path == lastPath;
    //   });
    //   if (item !=null) {
    //     onPressSingleItemFunc(item);
    //   }
    // }
  }

  AsyncIpcClient ipc() {
    return denoLibSocketLife.ipc();
  }

  void _insertIntoEditor(String content,
      {String editorId, String force = 'false'}) {
    print("_insertIntoEditor isShowing ${web.isShowing} ${editorId}");
    
    if (!injectJsFinished) {
      Future.delayed(Duration(milliseconds: 200), () {
        _insertIntoEditor(content, editorId: editorId, force: force);
      });
      return ;
    }

    // if (web.needInsertFirst) {
    //   web.toggleInsertFirst();
    // }

    if (editorId == null) {
      editorId = currentFilePath;
    }

    if (!editorId.startsWith("_")) {
      editorId = "_" + editorId;
    }

    if(Platform.isWindows) {
      editorId = editorId.replaceAll("\\","\\\\");
    }
    web.insertByContentNId(content, editorId, force: force);
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

  void showCommonSnack({String msg, String error}) {
    Color bkGC = null;
    bkGC = ColorManager.Get("snackbackground");
    if (error != null) {
      msg = error;
      bkGC = Color(0xffffbcd4);
    }

    if (msg == null) {
      msg = TextK.Get("ERRRRRRRRRRRRRRR");
    }
    
    setState(() {
      snackColor = bkGC;
      // snackText =  TextK.Get(msg);
      snackTextList.add(snackText);
    });
    Future.delayed(Duration(seconds: 3), () {
      setState(() {
        snackColor = ColorManager.Get('cardbackground');
        snackTextList.removeAt(0);
      });
    });
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
        if (!data.hasError()) {
          _refresh();
        } else {
          print("_saveFile " + data.error().toString());
        }
      });
    }).catchError((err) {
      showCommonSnack(msg: null, error: err.toString());
    });
  }

  void _refresh({bool justUi = false}) {
    if (justUi) {
      setState(() {
        for (KfToDoTagData item in dataTags) {
          item.randomColor();
        }
      });
    } else {
      this.ipc().send(KfToDoIpcData.from('onFirstConnect',
          {'resourcePath': DenkuiRunJsPathHelper.GetResourcePath()}).json());
    }
  }

  void onReadLocalHistory() {
    if (isReadingLocalHistory) {
      setState(() {
        isReadingLocalHistory = false;
      });
    } else {
      setState(() {
        isReadingLocalHistory = true;
        searchTagField = null;
        searchKey = '';
      });
      // 1. 拿到当前正在编辑的文件路径

      var map = Map<String, dynamic>();
      map['path'] = GetDirFromPath(currentFilePath) +
          DirSpelator +
          _currentPathcontroller.text;
      var omap = Map<String, dynamic>();

      omap['data'] = map;
      omap['invokeName'] = 'readLocalHistory';
      this.ipc().invoke(KfToDoIpcData.from("invoke", omap), callback: ((data) {
        var ktoData = KfToDoIpcData.fromAsync(data);
        var historys = ktoData.data['history'] as List<Object>;
        historys.sort(((a, b) {
          var datea = (int.parse((a as dynamic)['name']));
          var dateb = (int.parse((b as dynamic)['name']));
          return datea - dateb;
        }));
        setState(() {
          localHistoryDatas = historys;
        });
      }));
    }
  }

  void CommonReadFile(String path,
      {Function({String content, String path, bool suc}) func,
      bool showError = true,
      bool callbackOnError = false}) {
    _readFile(path, callback: (AsyncIpcData data) {
      var ktoData = KfToDoIpcData.fromAsync(data);
      // print("CommonReadFile _readFile callback" + ktoData.toString());
      String path = ktoData.data['path'] as String;
      String error = ktoData.data['error'];
      if (error != null) {
        if (showError) {
          showCommonSnack(error: error);
        }
        if (callbackOnError) {
          func(content: '', path: path, suc: false);
        }
        return;
      }
      dynamic content = ktoData.data['content'];
      if (content != null) {
        if (content.runtimeType == String) {
          String content = ktoData.data['content'] as String;
          content = content?.replaceAll('\t', '    ');
          func(content: content, path: path, suc: true);
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

  void ensureLoadEditor() {
      web.loadCefContainer();

      web.executeJs(
          'if (!location.href.startsWith("http://localhost")) { location.href =  "${getDefaultUrl()}"}');
  }

  void onPressSingleItemFunc(ListItemData itemData) {
    print('onPressSingleItemFunc ' + itemData.type);
    if (itemData.path.startsWith('http://') ||
        itemData.path.startsWith('https://')) {
      setState(() {
        currentFilePath = '';
        filePathLabelText = '';
      });
      web.executeJs('window.open("${itemData.path}","_self")');
    } else {
      ensureLoadEditor();

      CommonReadFile(itemData.path, func: ({content, path, suc}) {
        currentFilePath = path.replaceAll("\\", DirSpelator);
        print(
            "path ${path} ${currentFilePath} ${"\\"} ${DirSpelator}\n\n\n\n----------------");
        content = content.replaceAll('\t', '    ');
        _refreshFilePathTextField();
        web.executeJs(
            'window.denkGetKey("funcSwitchDarkMode")(${ColorManager.instance().isDarkmode ? 'true' : 'false'},"onPressSingleItemFunc")');
        _insertIntoEditor(content);

        print("switch to darkmode ${ColorManager.instance().isDarkmode}");
        var jsCode =
            "window.denkSetKeyValue('dataList', decodeURIComponent(\"${Uri.encodeComponent(this.data.json)}\"))";
        // print("jsCode ${jsCode}");
        web.executeJs(jsCode);
        web.executeJs("window.denkGetKey('funcUpdateSuggestions')()");
      });
    }
  }

  void onLongPressSingleItemFunc(ListItemData itemData) {
    DenktuiDialog.initContext(context);
    DenktuiDialog.ShowCommonDialog(
        contentTitle: TextK.Get("Delete this item"),
        options: [
          CommonDialogButtonOption(
              text: TextK.Get("Delete"),
              callback: () {
                this.onPressDeleteFunc(itemData);
              },
              icon: Icons.delete),
          CommonDialogButtonOption(
              text: TextK.Get("Cancel"), callback: () {}, icon: Icons.cancel)
        ]);
  }

  void onPressAddNewFunc() {
    DenktuiDialog.initContext(context);

    var content = Container();

    if (dialogCurrentFocus == "markdown") {
      content = Container(
        child: Column(
          children: [
            ListTile(
              leading: Icon(
                Icons.text_format,
                color: ColorManager.Get("textdarkr"),
              ),
              title: Text(
                TextK.Get('Markdown'),
                style: TextStyle(color: ColorManager.Get("textdarkr")),
              ),
              subtitle: Text(
                TextK.Get('Add a markdown file '),
                style: TextStyle(color: ColorManager.Get("textdarkr")),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: TextFormField(
                initialValue: '',
                style: TextStyle(color: ColorManager.Get("font")),
                onChanged: (String value) {
                  this.dialog_editor_blog_file_name = value;
                },
                decoration: InputDecoration(
                  labelText: TextK.Get('markdown file name'),
                  labelStyle: TextStyle(color: ColorManager.Get("textdarkr")),
                  fillColor: ColorManager.Get("textr"),
                  helperStyle: TextStyle(color: ColorManager.Get("textdarkr")),
                  enabledBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorManager.Get("textdarkr")),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: ColorManager.Get("textdarkr")),
                  ),
                  suffix: MaterialButton(
                    color: ColorManager.Get("textdarkr"),
                    textColor: ColorManager.Get("font"),
                    child: Text(".md", ),),
                ),
              ),
            ),
            Container(height: 45),
            ViewBuilder.BuildMaterialButton(TextK.Get("Add to List"),
                color: ColorManager.Get("textdarkr"),
                isRevert: true,
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
                String initContent = ktoData.data['content'] as String;
                String path = ktoData.data['path'] as String;
                String name = DateTime.now().microsecond.toString();
                if (this.dialog_editor_blog_file_name != "") {
                  name = this.dialog_editor_blog_file_name;
                } else {
                  showCommonSnack(error: TextK.Get("请输入有效的文件名称"));
                  return;
                }
                String newFilePath = path + DirSpelator + name + ".md";

                ensureLoadEditor();
                // check is already has this file
                CommonReadFile(newFilePath,
                    showError: false,
                    callbackOnError: true, func: (({content, path, suc}) {
                      print("Add to list callback");
                  if (!suc) {
                    currentFilePath = newFilePath;
                    _refreshFilePathTextField();
                    initContent = initContent.replaceFirst(
                        "\$\{title\}", TextK.Get("请输入你的标题"));
                    initContent = initContent.replaceFirst(
                        "\$\{tag\}", TextK.Get("第一个标签"));
                    _insertIntoEditor(initContent, editorId: currentFilePath);
                    isWriteWithoutRead = true;
                  } else {
                    showCommonSnack(error: TextK.Get("请检查是否已存在同名文件"));
                  }
                }));
              });
            })
          ],
        ),
      );
    } else {
      content = Container(
        child: Column(children: [
          ListTile(
            leading: Icon(
              Icons.rss_feed,
              color: ColorManager.Get("textdarkr"),
            ),
            title: Text(
              'RSS',
              style: TextStyle(color: ColorManager.Get("textdarkr")),
            ),
            subtitle: Text(
              TextK.Get('Add a rss '),
              style: TextStyle(color: ColorManager.Get("textdarkr")),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: TextFormField(
              initialValue: 'http://',
              style: TextStyle(color: ColorManager.Get("font")),
              onChanged: (String value) {
                this.dialog_editor_rss_url = value;
              },
              
              decoration: InputDecoration(
                labelText: TextK.Get('RSS url'),
                labelStyle: TextStyle(color: ColorManager.Get("textdarkr")),
                helperText: TextK.Get('Input a rss url '),
                fillColor: ColorManager.Get("textr"),
                helperStyle: TextStyle(color: ColorManager.Get("textdarkr")),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: ColorManager.Get("textdarkr")),
                ), 
              ),
            ),
          ),
            Container(height: 45),
          ViewBuilder.BuildMaterialButton(TextK.Get("Add to List"),

                icon: Icon(
                  Icons.newspaper,
                  color: ColorManager.Get("textdarkr"),
                  size: ViewBuilder.size(2),
                ),
          isRevert: true,
              color: ColorManager.Get("textdarkr"), onPressFunc: () {
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
      );
    }

    DenktuiDialog.ShowDialog(
        content: Container(
          width: 500,
          height: 307,
          alignment: Alignment.center,
          color: ColorManager.Get("cardbackground"),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                child: Row(
                  children: [
                    MaterialButton(
                        onPressed: () {
                          dialogCurrentFocus = "markdown";

                          Navigator.pop(context);
                          onPressAddNewFunc();
                        },
                        color: dialogCurrentFocus == "markdown"
                                  ? ColorManager.Get("textr") : null,
                        hoverColor: ColorManager.Get("textr"),
                        textColor: dialogCurrentFocus == "markdown"
                                  ? ColorManager.Get("font")
                                  : ColorManager.Get("textr"),
                        child: Text(
                          "makrdown",
                        )),
                    Container(width: 20,),
                    MaterialButton(
                        onPressed: () {
                          dialogCurrentFocus = "rss";
                          Navigator.pop(context);
                          onPressAddNewFunc();
                        },
                        color: dialogCurrentFocus == "rss" ? ColorManager.Get("textr") : null,
                        textColor: dialogCurrentFocus == "rss"
                                  ? ColorManager.Get("font")
                                  : ColorManager.Get("textr"),
                        hoverColor: ColorManager.Get("textr"),
                        child: Text("rss"))
                  ],
                ),
              ),
              content
            ],
          ),
        ),
        children: []);
  }

  void onPressDeleteFunc(ListItemData itemData) {
    handleRemoveThis(itemData);
  }

  Widget buildLoadingItem() {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: ColorManager.Get('cardbackground'),
      child: Column(
        children: [
          Loading(
            indicator: BallPulseIndicator(),
            size: 100.0,
            color: ViewBuilder.RandomColor(),
          )
        ],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  Card ACard(Widget widget) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: widget,
      color: ColorManager.Get("cardbackground"),
    );
  }

  void onDragLineStart(PointerDownEvent event) {
    
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
        if (left_width_real < 10) {
          left_width_real = 10;
        }
      });
    }
  }

  void onDragLineEnd() {
    setState(() {
      FlutterDesktopCefWeb.allWebViews.forEach((element) {
        if (!isTreeCardMode) {
          element.show();
        }
      });
      web.loadCefContainer();
    });
    isDragingLine = false;
  }

  List<Widget> buildListItemView(String tag, KfToDoTagData tagData) {
    List<Widget> res = [];
    this.data.data.where((element) => element.tags.contains(tag)).forEach((e) {
      res.add(
        ViewBuilder.BuildSingleTagListItemContainor(e,
            tagData: tagData,
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

  Widget buildSnackListView() {

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [ Container(
      child: Column(
        children: this.snackTextList.map((e) {
          return Container(
            margin: EdgeInsets.fromLTRB(ViewBuilder.size(3),ViewBuilder.size(0.5),ViewBuilder.size(3),0),
          
            child: Card(color: ColorManager.Get('cardbackground'),
            child: ViewBuilder.BuildInLineMaterialButton(e,color: ColorManager.Get('font') ,icon: Icon(Icons.info, color: ColorManager.Get('font'), size: ViewBuilder.size(2),)))
          );
        }).toList(),
      ),
    )],
    );
  }

  Widget buildLocalHistoryView() {
    return ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          if (this.localHistoryDatas.length == 0) {
            return buildLoadingItem();
          } else {
            var date = new DateTime.fromMillisecondsSinceEpoch(
                int.parse((localHistoryDatas[index] as dynamic)['name']));
            var path = (localHistoryDatas[index] as dynamic)['path'];
            return ViewBuilder.BuildMaterialButton(date.toString(),
                onPressFunc: () {
              CommonReadFile(path, func: ({content, path, suc}) {
                _insertIntoEditor(content, force: 'true');
              });
            });
          }
        },
        itemCount: this.localHistoryDatas.length);
  }
  

  Widget buildListView() {
    bool hasItems = this.data?.data != null || this.searchedTags.length != 0;
    return Container(
      margin: Platform.isWindows ? EdgeInsets.all(0) : EdgeInsets.fromLTRB(0, 24, 0, 0),
      child: Column(
        children: [
          hasItems ? searchTagField.view() : Container(),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemBuilder: (BuildContext context, int index) {
                  if (this.searchedTags.length == 0) {
                    return buildLoadingItem();
                  } else {
                    var element = this.searchedTags[index];
                    var childViewList = this.buildListItemView(element.name, element);
                    if (childViewList.length > 0 || true) {
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
      ),
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
      }, onRefresh: () {
        setState(() {
          
        });
      });
    }

    var listModeChilds = [
      new Container(
        width: left_width_real,
        padding: EdgeInsets.zero,
        child: Card(
          clipBehavior: Clip.antiAlias,
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                  child: Stack(children: [
                    isReadingLocalHistory
                      ? Container(
                          width: left_width_real,
                          child: buildLocalHistoryView(),
                        )
                      : buildListView(),
                      buildSnackListView()
                  ],)),
              Listener(
                  onPointerDown: (event) => {onDragLineStart(event)},
                  onPointerUp: ((event) => {onDragLineEnd()}),
                  onPointerMove: ((event) {
                    onDragLineMoving(event);
                  }),
                  child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                      width: 4,
                      height: double.infinity,
                      alignment: Alignment.center,
                      child: Container(
                        width: 2,
                        height: 20,
                      )))),
            ],
          ),
          color: ColorManager.Get("cardbackground"),
        ),
      ),
       Expanded(
              child: Container(
              child: Card(
                margin: EdgeInsets.zero,
                color: ColorManager.Get("cardbackground"),
                child: Column(
                  children: [
                    new Container(
                      height: 60,
                      child: Row(
                        children: [
                          filePathLabelText.isEmpty
                              ? Container()
                              : ViewBuilder.BuildMaterialButton(
                                  TextK.Get("保存"),
                                  onPressFunc: () {
                                    _saveFile();
                                  },
                                  color: ColorManager.Get("textdarkr"),
                                  icon: Icon(
                                    Icons.save_as_sharp,
                                    color: ColorManager.Get("textdarkr"),
                                    size: ViewBuilder.size(2),
                                  ),
                                ),
                          filePathLabelText.isEmpty
                              ? Container()
                              : ViewBuilder.BuildMaterialButton(
                                  TextK.Get("历史记录"), onPressFunc: () {
                                  // _saveFile();
                                  onReadLocalHistory();
                                },
                                  color: ColorManager.Get("textdarkr"),
                                  backgroundColor: isReadingLocalHistory
                                      ? ColorManager.Get("cardbackgrounddark")
                                      : ColorManager.Get("cardbackground"),
                                  icon: Icon(
                                    Icons.history_sharp,
                                    color: ColorManager.Get("textdarkr"),
                                    size: ViewBuilder.size(2),
                                  )),
                          this.searchedTags.length == 0
                              ? Container()
                              : ViewBuilder.BuildMaterialButton(
                                  TextK.Get("新建..."),
                                  onPressFunc: () => this.onPressAddNewFunc(),
                                  color: ColorManager.Get("textdarkr"),
                                  icon: Icon(
                                    Icons.edit,
                                    color: ColorManager.Get("textdarkr"),
                                    size: ViewBuilder.size(2),
                                  )),
                          Container(
                            color: filePathLabelText.isEmpty
                                ? null
                                : ColorManager.Get("textdarkr"),
                            margin: EdgeInsets.symmetric(
                                vertical: ViewBuilder.size(1)),
                            width: 5,
                          ),
                          Expanded(
                              child: Container(
                            margin: EdgeInsets.symmetric(
                                vertical: ViewBuilder.size(1)),
                            child: Column(
                              children: [
                                filePathLabelText.isNotEmpty ?  MaterialButton(
                                    height: ViewBuilder.size(1.5),
                                    onPressed: () {
                                      // TODO: 这里需要兼容Windows
                                      if (filePathLabelText.isNotEmpty) {

                                        ChildProcess(ChildProcessArg.from(
                                                "${Platform.isWindows ? "start" : "open"} ${filePathLabelText}"))
                                            .run();
                                      }
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: ViewBuilder.size(1)),
                                      child: Row(
                                        children: [
                                          Text(filePathLabelText,
                                              style: TextStyle(
                                                  color: ColorManager.Get(
                                                      'textr')))
                                        ],
                                      ),
                                    )) :Container(),
                                Container(
                                  padding: EdgeInsets.only(
                                      left: ViewBuilder.size(2),
                                      top: ViewBuilder.size(1)),
                                  child: Row(children: [
                                    Text(GetFileNameFromPath(currentFilePath),
                                        style: TextStyle(
                                            color: ColorManager.Get("font")))
                                  ]),
                                )
                              ],
                            ),
                            // child: TextField(
                            //     controller: _currentPathcontroller,
                            //     style:
                            //         TextStyle(color: ColorManager.Get("font")),
                            //     decoration: InputDecoration(
                            //         fillColor: null,
                            //         border: OutlineInputBorder(
                            //             borderRadius: const BorderRadius.all(
                            //                 Radius.circular(8))),
                            //         focusColor: Colors.white,
                            //         // labelText: filePathLabelText,
                            //         label: Container(
                            //           margin: EdgeInsets.fromLTRB(
                            //               0, ViewBuilder.size(3.5), 0, 0),
                            //           // color: Colors.black,
                            //           child: Text(
                            //             filePathLabelText,
                            //             style: TextStyle(
                            //                 color:
                            //                     ColorManager.Get("textdarkr")),
                            //           ),
                            //         ),
                            //         // labelStyle: TextStyle(
                            //         //   color: ViewBuilder.RandomDarkColor()r
                            //         // ),
                            //         enabled: false,
                            //         disabledBorder: OutlineInputBorder(
                            //           borderSide:
                            //               BorderSide(color: Color(0x00000000)),
                            //         ),
                            //         focusedBorder: OutlineInputBorder(
                            //           borderSide:
                            //               BorderSide(color: Color(0x00000000)),
                            //         ),
                            //         enabledBorder: OutlineInputBorder(
                            //           borderSide:
                            //               BorderSide(color: Color(0x00000000)),
                            //         )),
                            //     onTap: () {
                            //       print("onTap ${filePathLabelText}");
                            //       ChildProcess(ChildProcessArg.from("open ${filePathLabelText}")).run();
                            //     },),
                          ))
                        ],
                      ),
                    ),
                    cefWidget
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
                children: listModeChilds,
              ),
            ),
            Container(
                height: 28,
                width: double.infinity,
                color: Colors.white12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: left_width_real,
                      child: Row(
                      children: [
                        snackText.length > 0 ? ViewBuilder.BuildInLineMaterialButton(snackText,
                            color: snackColor,backgroundColor: ViewBuilder.RandomColor()) : Container()
                      ],
                    ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                       
                        ViewBuilder.BuildInLineMaterialButton(
                            TextK.Get("DarkMode"), onPressFunc: () {
                          setState(() {
                            ColorManager.instance().isDarkmode =
                                !ColorManager.instance().isDarkmode;
                          });
                          _flutterDesktopFileManagerPlugin.onUpdateDarkMode(
                              ColorManager.instance().isDarkmode);
                          web.executeJs(
                              'window.denkGetKey("funcSwitchDarkMode")(${ColorManager.instance().isDarkmode ? 'true' : 'false'})');

                          var config = {};
                          config['isDarkmode'] =
                              ColorManager.instance().isDarkmode;
                        },
                            color: ColorManager.Get("textdarkr"),
                            withText: false,
                            icon: Icon(
                              !ColorManager.instance().isDarkmode
                                  ? Icons.dark_mode
                                  : Icons.dark_mode_outlined,
                              color: ColorManager.Get("textdarkr"),
                              size: ViewBuilder.size(false ? 2 : 2),
                            )),
                        ViewBuilder.BuildInLineMaterialButton(
                            TextK.Get("Re-Random Color"), onPressFunc: () {
                          setState(() {
                            ColorManager.rerandom();
                            _refresh(justUi: true);
                          });
                        },
                            color: ColorManager.Get("textdarkr"),
                            withText: false,
                            icon: Icon(
                              Icons.color_lens,
                              color: ColorManager.Get("textdarkr"),
                              size: ViewBuilder.size(false ? 2 : 2),
                            )),
                        ViewBuilder.BuildInLineMaterialButton(
                            TextK.Get("Switch Language"), onPressFunc: () {
                          setState(() {
                            TextK.toggle();
                          });
                        },
                            color: ColorManager.Get("textdarkr"),
                            withText: false,
                            icon: Icon(
                              Icons.language,
                              color: ColorManager.Get("textdarkr"),
                              size: ViewBuilder.size(false ? 2 : 2),
                            )),
                        ViewBuilder.BuildInLineMaterialButton(
                            TextK.Get("Reload Editor"), onPressFunc: () {
                          web.executeJs("location.reload(false)");
                        },
                            color: ColorManager.Get("textdarkr"),
                            withText: false,
                            icon: Icon(
                              Icons.refresh,
                              color: ColorManager.Get("textdarkr"),
                              size: ViewBuilder.size(false ? 2 : 2),
                            )),
                        ViewBuilder.BuildInLineMaterialButton(
                            TextK.Get("Reset WorkSpace"), onPressFunc: () {
                          this.ipc().invokeNyName({"invokeName": "getConfig"},
                              callback: (AsyncIpcData data) {
                            var ktoData = KfToDoIpcData.fromAsync(data);

                            initConfigDirectory(ktoData.data,
                                title: TextK.Get('是否重新选择文件目录'));
                          });
                        },
                            color: ColorManager.Get("textdarkr"),
                            withText: false,
                            icon: Icon(
                              Icons.settings,
                              color: ColorManager.Get("textdarkr"),
                              size: ViewBuilder.size(false ? 2 : 2),
                            )),
                      ],
                    ),
                  ],
                ))
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
