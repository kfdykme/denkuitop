
import 'dart:convert';

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

  ListData(String json): this.fromMap(jsonDecode(json));

  ListData.fromMap(Map<String, dynamic> map) {
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

class KfToDoTagData {
  final String name;
  bool isOpen = false;
  Color darkColor= ViewBuilder.RandomDarkColor();
  Color darkColor2 =  ViewBuilder.RandomDarkColor();
  Color lightColor = ViewBuilder.RandomColor();
  Color lightColor2  = ViewBuilder.RandomColor();

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
}
