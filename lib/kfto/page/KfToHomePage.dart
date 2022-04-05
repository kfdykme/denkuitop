import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:denkuitop/common/Logger.dart';
import 'package:denkuitop/common/Os.dart';
import 'package:denkuitop/common/Path.dart';
import 'package:denkuitop/common/Toast.dart';
import 'package:denkuitop/denkui/child_process/ChildProcess.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcClient.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/libdeno/LibraryLoader.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:flutter/material.dart';
import 'package:quill_delta/quill_delta.dart';
import 'package:zefyrka/zefyrka.dart';

ZefyrController _controller = ZefyrController();

Logger logger = Logger("KfToHomeState");

class KfToHomePage extends BaseRemotePage {
  @override
  BaseRemotePageState createState() {
    return KfToHomeState();
  }
}

class KfToHomeState extends BaseRemotePageState {
  var isFirstConnect = false;

  ListData data = null;

  String currentFilePath = '';
  String filePathLabelText = 'File Path';
  TextEditingController _currentPathcontroller;

  var highLightColor = const Color(0xFF6200EE);

  LibraryLoader lib ;

  KfToHomeState() {
    this.lib = LibraryLoader();
    this.lib.libMain("deno run -A --import-map=../de2/import_map.json --unstable ..\\de2\\src\\start\\run.ts --port=8082");
    super.init(client: new AsyncIpcClient(), port: 8082);

    this.ipc().setCallback("onmessage", (String message) async {
      print(message);
      handleIpcMessage(new KfToDoIpcData(message));
    });
    this._currentPathcontroller = TextEditingController();

  }

  void handleIpcMessage(KfToDoIpcData data) {
    if (!isFirstConnect) {
      this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
      isFirstConnect = true;
    }
    if (data.name == 'initData') {
      setState(() {
        this.data = ListData.fromMap(data.data as Map<String, dynamic>);
      });
    }
  }

  @override
  AsyncIpcClient ipc() {
    return super.ipc() as AsyncIpcClient;
  }

  void _clearEditor() {
    setState(() {
      var document = NotusDocument();
      _controller = ZefyrController(document);
      _controller.formatText(0, 1, NotusAttribute.block.code);
    });
  }

  void _insertIntoEditor(String content) {
    _clearEditor();
    setState(() {
      _controller.document.insert(0, content);
    });
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

  void _saveFile() {
    var map = Map<String, dynamic>();
    map['path'] = GetDirFromPath(currentFilePath) +
        DirSpelator +
        _currentPathcontroller.text;
    map['content'] = _controller.document.toPlainText();
    var omap = Map<String, dynamic>();

    omap['data'] = map;
    omap['invokeName'] = 'writeFile';
    this.ipc().invoke(KfToDoIpcData.from("invoke", omap),
        callback: (AsyncIpcData data) {
      _refresh();
    });
  }

  void _refresh() {
    this.ipc().send(KfToDoIpcData.from('onFirstConnect', null).json());
  }

  Widget buildSingleListItem(ListItemData itemData) {
    var backColor = currentFilePath == itemData.path ? Colors.black.withOpacity(0.6): Colors.white;
    var forColor = currentFilePath == itemData.path ? Colors.white: Colors.black.withOpacity(0.6);
    return FlatButton(
      textColor: this.highLightColor,
      onPressed: () {
        var map = new Map<String, dynamic>();
        map['invokeName'] = 'readFile';
        map['data'] = itemData.path;
        this.ipc().invoke(KfToDoIpcData.from('invoke', map),
            callback: (AsyncIpcData data) {
          var ktoData = KfToDoIpcData.fromAsync(data);
          String content = ktoData.data['content'] as String;
          String path = ktoData.data['path'] as String;
          currentFilePath = path;
          content = content.replaceAll('\t', '    ');
          _refreshFilePathTextField();
          _insertIntoEditor(content);
        });
      },
      onLongPress: () {
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
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        color: backColor,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.arrow_drop_down_sharp, color:forColor),
              title: Text('${itemData.title}', style:  TextStyle(color:forColor)),
              subtitle: Text(
                '${itemData.date}\n${GetFileNameFromPath(itemData.path)}',
                style: TextStyle(color:forColor),
              ),
            ),
          ],
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget buildAddNewButtonItem() {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          FlatButton(
            textColor: this.highLightColor,
            onPressed: () {
              var map = new Map();
              map['invokeName'] = "getNewBlogTemplate";
              this.ipc()?.invoke(KfToDoIpcData.from("invoke", map),
                  callback: (AsyncIpcData data) {
                var ktoData = KfToDoIpcData.fromAsync(data);
                String content = ktoData.data['content'] as String;
                _insertIntoEditor(content);
                _saveFile();
              });
            },
            child: const Text('Add New'),
          )
        ],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  Widget buildDeleteButtonItem(ListItemData itemData, BuildContext context) {
    return FlatButton(
      textColor: this.highLightColor,
      onPressed: () {
        Navigator.of(context).pop();
        handleRemoveThis(itemData);
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

  List<Widget> buildListItem() {
    List<Widget> list = [];
    var size = 10;
    if (this.data?.data != null) {
      this.data.data.forEach((element) {
        list.add(buildSingleListItem(element));
      });
    } else {
      list.add(buildLoadingItem());
    }
    return list;
  }

  Card ACard(Widget widget) {
    return Card(clipBehavior: Clip.antiAlias, child: widget);
  }

  @override
  Widget build(BuildContext context) {
    const MAX_WIDTH = 1280 - 25;
    const RIGHT_WIDTH = 1280 * 0.618;
    const LEFT_WIDTH = MAX_WIDTH - RIGHT_WIDTH;
    _controller.formatText(0, 1, NotusAttribute.block.code);

    // if (!File('../denkui').existsSync()) {
    //   ChildProcess(ChildProcess.PRE_PARE_DENKUI).run();
    // }
    
    var childs = [
      new Container(
        width: LEFT_WIDTH,
        color: Colors.white,
        child: ACard(Stack(
          children: [
            new ListView(
              padding: new EdgeInsets.all(8),
              children: [ACard(Column(children: buildListItem()))],
            ),
            // new Column(
            //   children: [buildAddNewButtonItem()],
            // )
          ],
        )),
      ),
      new Container(
          width: RIGHT_WIDTH,
          color: Colors.white,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
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
                                borderRadius: const BorderRadius.all(Radius.circular(8))
                              ),
                              focusColor: this.highLightColor,
                              labelText: filePathLabelText,
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: this.highLightColor),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )
                            ),
                            onChanged: _onFilePathInputChange,
                          )),
                      margin: const EdgeInsets.all(4),
                    ),
                    new Builder(builder: (BuildContext context2) {
                      return FlatButton(
                        textColor: this.highLightColor,
                        onPressed: () {
                          _saveFile();
                        },
                        child: const Text('Save'),
                      );
                    }),
                    buildAddNewButtonItem()
                  ],
                ),
                Expanded(
                  child: ZefyrEditor(
                    controller: _controller,
                  ),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
          ))
    ];
    return new Container(
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: childs,
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
