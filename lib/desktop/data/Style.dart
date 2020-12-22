import 'package:flutter/material.dart';

class Style {
  String header = "";
  List<dynamic> body = new List.empty();
  bool isClose = false;

  Style.from(dynamic e) : this(e as Map<String, dynamic>);

  Style.empty();

  Style(Map<String, dynamic> data)
      : header = data['header'],
        body = (data['body'] as List<dynamic>),
        isClose = (data['isClose'] as bool);

  @override
  String toString() {
    // TODO: implement toString
    return "${header} \{\n${body.join('\n')}\}";
  }

  hasHeight() {
    return this
            .body
            ?.where((element) => (element as String).contains("height"))
            .length >
        0;
  }

  static var STYLE_HEIGHT_MAX = 400.0;

  height() {
    if (hasHeight()) {
      var height = (this
              .body
              ?.where((element) => (element as String).contains("height"))
              .last as String)
          .split(":")[1]
          .replaceAll(";", "")
          .replaceAll("px", "")
          .trim();
      if (height == "100%") {
        return STYLE_HEIGHT_MAX;
      }
      return double.parse(height);
    } else {
      return STYLE_HEIGHT_MAX;
    }
  }

  hasCss(String name) {
    return this
            .body
            ?.where((element) => (element as String).contains(name))
            .length >
        0;
  }

  getCssSize(String name) {
    if (hasCss(name)) {
      var size = (this
              .body
              ?.where((element) => (element as String).contains(name))
              .last as String)
          .split(":")[1]
          .trim()
          .toUpperCase()
          .replaceAll(";", "")
          .replaceAll("PX", "");
      print(size);
      return double.parse(size) / 2;
    }
    return null;
  }

  getCssColor(String name) {
    if (hasCss(name)) {
      var color = (this
              .body
              ?.where((element) => (element as String).contains(name))
              .last as String)
          .split(":")[1]
          .trim()
          .toUpperCase()
          .replaceAll("#", "FF")
          .replaceAll(";", "");
      print(color);
      return Color(int.parse(color.trim(), radix: 16));
    }
    return null;
  }

  hasBackgroundColor() {
    return this
            .body
            ?.where(
                (element) => (element as String).contains("background-color"))
            .length >
        0;
  }

  backgroundColor() {
    if (hasBackgroundColor()) {
      var color = (this
              .body
              ?.where(
                  (element) => (element as String).contains("background-color"))
              .last as String)
          .split(":")[1]
          .trim()
          .toUpperCase()
          .replaceAll("#", "FF")
          .replaceAll(";", "");
      print(color);
      return Color(int.parse(color.trim(), radix: 16));
    }
    return null;
  }
}
