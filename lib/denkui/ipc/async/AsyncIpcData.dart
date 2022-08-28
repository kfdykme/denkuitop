import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';

class AsyncIpcData {
  String _id = null;

  String get id {
    if (_id == null) {
      GenerateId();
    }
    return this._id;
  }

  bool wait = false;
  bool isResponse = false;
  String raw = '';
  Map<String, dynamic> rawMap;
  static int S_GLOBAL_ID_COUNT = 0;

  AsyncIpcData() {}

  AsyncIpcData.raw(String message) {
    raw = message;
    rawMap = jsonDecode(raw);
    _id = rawMap['id'];
    isResponse = rawMap['isResponse'];
  }

  String GenerateId() {
    var id = "async-" + S_GLOBAL_ID_COUNT.toString();
    S_GLOBAL_ID_COUNT++;
    this._id = id;
    return id;
  }

  AsyncIpcData isWait() {
    wait = true;
    return this;
  }

  AsyncIpcData isRep() {
    isResponse = true;
    return this;
  }

  Map<String, dynamic> map() {
    if (_id == null) {
      GenerateId();
    }
    var map = new Map<String, dynamic>();
    map['id'] = _id;
    map['wait'] = wait;
    map['isResponse'] = isResponse;
    return map;
  }

  bool hasError() {
    return this.rawMap['data']['error'] == null;
  }

  String json() {
    return jsonEncode(map());
  }

  String toString() {
    return json();
  }
}
