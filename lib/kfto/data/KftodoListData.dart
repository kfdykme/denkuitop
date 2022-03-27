
import 'dart:convert';

import 'package:denkuitop/denkui/ipc/async/AsyncIpcData.dart';

class ListItemData {
  final String title;
  final String date;
  final List<String> tags;
  final String path;
  ListItemData.forMap(Map<String,dynamic> map):
    title = map['title'],
    date = map['date'],
    path = map['path'],
    tags = List<String>.from(map['tags'] as List<dynamic>);
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
