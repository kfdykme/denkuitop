

import 'dart:convert';

class View {
  String content = "";
  String renderContent = "";
  Map<String,dynamic> jsonParams = new Map();
  String name = "";
  List<View> childs = new List.empty();

  View.fromString(String jsonString): this(jsonDecode(jsonString));

  View.from(dynamic e): this(e as Map<String,dynamic>);

  View(Map<String,dynamic> data):
      name = data['name'],
      jsonParams = data['jsonParams'],
      content = data['content'],
      renderContent = data['renderContent'],
      childs = (data['childs'] as List<dynamic>)
          .map((dynamic e) =>  View.from(e))
          .toList();//.map((dynamic e) => new View(e as Map<String,dynamic>));


  @override
  String toString() {
    // TODO: implement toString
    return "{ ${name} -> { 'content': ${content}, 'jsonParams': ${jsonParams} childs: ${childs.toString()}}";
  }
}