
import 'dart:convert';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/cupertino.dart';

class ListItemData {
  final String title;
  final String date;
  final List<String> tags;
  final String path;
  final String type;

  ListItemData.forMap(Map<String,dynamic> map):
    title = map['title'],
    date = map['date'],
    path = map['path'],
    type = map['type'] == null ? 'normal' : map['type'],
    tags = map['tags'] == null ? [] : List<String>.from(map['tags'] as List<dynamic>);
}

class ListData {

  List<ListItemData> data = [];

  String json = "{}";

  ListData(String json): this.fromMap(jsonDecode(json));
  


  ListData.fromMap(Map<String, dynamic> map) {
    this.json = jsonEncode(map);
    List<dynamic> infos = map['headerInfos'];
    infos.forEach((element) {
      
      data.add(ListItemData.forMap(element as Map<String, dynamic>));
    });
  }
}


class KfToDoIpcData  extends AsyncIpcData {
  final String name;
  final dynamic data;

  KfToDoIpcData(String json):this.fromMap(jsonDecode(json));
 
  @override
  KfToDoIpcData.raw(String message):
    name = jsonDecode(message)['name'],
    data = jsonDecode(message)['data'],
    super.raw(message);

  KfToDoIpcData.fromAsync(AsyncIpcData asyncIpcData):
    this.fromMap(asyncIpcData.rawMap);

  KfToDoIpcData.fromMap(Map<String,dynamic> map):
    name = map['name'],
    data = map['data'];

  KfToDoIpcData.from(String name, dynamic data):
    name = name,
    this.data = data;

  @override
  String json() {
    var ma = super.map();
    ma['name'] = name;
    ma['data'] = data; 
    return jsonEncode(ma);
  }
}

class KfTodoTagDataCache {
  static Map<String, bool> isOpen = new Map();
  static Map<String, Color> darkColor= new Map();
  static Map<String, Color> darkColor2 = new Map();
  static Map<String, Color> lightColor = new Map();
  static Map<String, Color> lightColor2 = new Map();

  
}

class KfToDoTagData {
  final String name;
  Color get darkColor  {
    if(KfTodoTagDataCache.darkColor[name] == null ) {
      KfTodoTagDataCache.darkColor[name] = ViewBuilder.RandomDarkColor() ;
    }
    return KfTodoTagDataCache.darkColor[name];
  }
  Color get darkColor2  {
    if(KfTodoTagDataCache.darkColor2[name] == null ) {
      KfTodoTagDataCache.darkColor2[name] = ViewBuilder.RandomDarkColor();
    }
    return KfTodoTagDataCache.darkColor2[name];
  }
  Color get lightColor  {
    if(KfTodoTagDataCache.lightColor[name] == null ) {
      KfTodoTagDataCache.lightColor[name] = ViewBuilder.RandomColor();
    }
    return KfTodoTagDataCache.lightColor[name];
  }
  Color get lightColor2  {
    if(KfTodoTagDataCache.lightColor2[name] == null ) {
      KfTodoTagDataCache.lightColor2[name] = ViewBuilder.RandomColor();
    }
    return KfTodoTagDataCache.lightColor2[name];
  }

  void set isOpen(value) {
    // _isOpen = value;
    KfTodoTagDataCache.isOpen[name] = value;
  }

  bool get isOpen {
    return  KfTodoTagDataCache.isOpen[name] == null ?  false: KfTodoTagDataCache.isOpen[name];
  }

  bool isRss = false;
  bool isRssItem = false;
  
  KfToDoTagData(String tag):
    name = tag;
    

  operator ==(Object other) =>
    identical(this, other) || 
    other is KfToDoTagData &&
    other.name == this.name;
  
  @override
  int get hashCode => this.name.hashCode;

  @override
  String toString() {
    return this.name;
  }

  void randomColor() {
      KfTodoTagDataCache.darkColor[name] = ViewBuilder.RandomDarkColor() ;
      KfTodoTagDataCache.darkColor2[name] = ViewBuilder.RandomDarkColor();
      KfTodoTagDataCache.lightColor[name] = ViewBuilder.RandomColor();
      KfTodoTagDataCache.lightColor2[name] = ViewBuilder.RandomColor();
  }
}
