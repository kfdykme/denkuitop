
import 'dart:convert';

class IpcData {
  final String method;
  final dynamic data;

  IpcData(String json):this.fromMap(jsonDecode(json));

  IpcData.fromMap(Map<String,dynamic> map):
    method = map['method'],
    data = map['data'];

}

