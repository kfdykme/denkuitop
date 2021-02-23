import 'package:flutter/material.dart';

class Style {
  String header = "";
  List<dynamic> body = new List.empty();
  bool isClose = false;

  Style.from(dynamic e) : this(e as Map<String, dynamic>);

  Style.empty();

  static const FLEX_DIRECTION = "flex-direction";
  static const FLEX_DIRECTION_ROW = 'row';
  static const FLEX_DIRECTION_COLUMN = 'column';

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
            ?.where((element) => (element as String).trim().startsWith(name))
            .length >
        0;
  }

  getCssAsString(String name) {
    return (this.body
        ?.where((element) => (element as String).trim().startsWith(name))
        .last as String);
  
  }

  flexDirection() {
    var direction = FLEX_DIRECTION_ROW;
    if (hasCss(FLEX_DIRECTION)) {
      direction = getCssAsString(FLEX_DIRECTION)
      .split(":")[1]
      .replaceAll(";", "")
      .trim();
      print("get $FLEX_DIRECTION $direction");
    }

    return direction;
  }
 

  getCssSize(String name) {
    if (hasCss(name)) {
      var size = (this
              .body
              ?.where((element) => (element as String).trim().startsWith(name))
              .last as String)
          .split(":")[1]
          .trim()
          .toUpperCase()
          .replaceAll(";", "")
          .replaceAll("PX", "");
      print('getCssSize $name $size');
      if (size.contains("%")) {
        return -1 * double.parse(size.replaceAll('%', '')) / 100;
      }
      return double.parse(size) / 2;
    }
    return null;
  }

  getCssColor(String name) {
    if (hasCss(name)) {
      var color = (this
              .body
              ?.where((element) => (element as String).trim().startsWith(name))
              .last as String)
          .split(":")[1]
          .trim()
          .toUpperCase()
          .replaceAll("\#", "FF")
          .replaceAll(";", "")
          // TODO
          .replaceAll('@PRIMARYCOLOR','FF00bcd4');
      print("getCssColor ${name} ${color} from ${body}");
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
          .replaceAll(";", "")
          .replaceAll('@PRIMARYCOLOR','FF00bcd4');
      print(color);
      return Color(int.parse(color.trim(), radix: 16));
    }
    return null;
  }
}
