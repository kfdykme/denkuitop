import 'dart:math';

import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:flutter/material.dart';

class ViewBuilder {
  static int RANDOM_COLOR_TOP = 255;
  static int RANDOM_COLOR_BOTTOM = 160;
  static double BASE_SIZE = 8;

  static double size(double level) {
    return BASE_SIZE * level;
  }

  static int RandomColorInt() {
    return ViewBuilder.RANDOM_COLOR_BOTTOM +
        new Random().nextInt(
            ViewBuilder.RANDOM_COLOR_TOP - ViewBuilder.RANDOM_COLOR_BOTTOM);
  }

  static int RandomColorDartInt() {
    return new Random().nextInt(ViewBuilder.RANDOM_COLOR_BOTTOM);
  }

  static Color RandomColor() {
    return Color.fromARGB(RANDOM_COLOR_TOP, ViewBuilder.RandomColorInt(),
        ViewBuilder.RandomColorInt(), ViewBuilder.RandomColorInt());
  }

  static Color RandomDarkColor() {
    return Color.fromARGB(RANDOM_COLOR_TOP, ViewBuilder.RandomColorDartInt(),
        ViewBuilder.RandomColorDartInt(), ViewBuilder.RandomColorDartInt());
  }

  static IconData getIconByTag (String tag) {
    if (tag == "_DENKUISCRIPT") {
      return Icons.javascript;
    } 

    return Icons.folder;
  }

  static Widget BuildSingleTagContainor(String tag,
      {Function onPressFunc,
      KfToDoTagData tagData,
      List<Widget> childListItems}) {
    if (childListItems == null) {
      childListItems = <Widget>[];
    }

    var tagContainorChilds = <Widget>[];
    tagContainorChilds.add(MaterialButton(
      padding:
          EdgeInsets.only(left: size(2), top: size(.75), bottom: size(.75)),
      onPressed: () {
        if (onPressFunc != null) {
          onPressFunc(tag);
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                getIconByTag(tag),
                color: tagData.lightColor2,
                size: size(3),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(size(1), 0, 0, 0),
                child: Text(
                  tag,
                  style: TextStyle(color: tagData.darkColor),
                ),
              ),
            ],
          ),
          Icon(
            tagData.isOpen
                ? Icons.arrow_drop_down_sharp
                : Icons.arrow_left_sharp,
            color: tagData.darkColor2,
            size: size(3),
          )
        ],
      ),
    ));
    if (tagData.isOpen) {
      tagContainorChilds.add(Container(
        padding: EdgeInsets.only(left: size(2)),
        child: Column(
          children: childListItems,
        ),
      ));
    }

    return Container(
      height: tagData.isOpen ? null : size(4),
      width: double.infinity,
      margin: EdgeInsets.all(size(1)),
      child: Column(children: tagContainorChilds),
      color: tagData.lightColor,
    );
  }

  static Widget BuildSingleTagListItemContainor(ListItemData e, { Function onPressFunc, Function onLongPressFunc}) {
    return MaterialButton(
      padding:
          EdgeInsets.only(left: size(2), top: size(.75), bottom: size(.75)),
      onPressed: () {
        if (onPressFunc != null) {
          onPressFunc(e);
        }
      },
      onLongPress: () {
        if (onLongPressFunc != null) {
          onLongPressFunc(e);
        }
      },
      child: Container( 
        height: size(4),
        width: double.infinity,
        color: Color(0x33FFFFFF),
        margin: EdgeInsets.all(size(1)), 
        padding: EdgeInsets.only(left: size(1)),
        child: Stack(
          alignment: AlignmentDirectional.center,
          children: [
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [Text('@${e.date}', style: TextStyle(color: Color(0xaaFFFFFF), overflow: TextOverflow.ellipsis),)],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [Text(e.title != null ? e.title : "empty")],
        ),
        ],)
      ),
    );
    ;
  }

  static Widget BuildMaterialButton(String text, { Function onPressFunc, Color color, Icon icon}) {
    List<Widget> buttonChildrenItems = [];
    if (icon != null) {
      buttonChildrenItems.add(icon);
    }
    buttonChildrenItems.add(Container(
      padding: EdgeInsets.only(left: size(1 )),
      child: Text(text),
    ));
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          MaterialButton( 
            textColor: color,
            onPressed: () {
              print("BuildMaterialButton Press ${text} ${onPressFunc}");
              if (onPressFunc != null) {
                onPressFunc();
              }
            },
            child: Row( 
              children: buttonChildrenItems,
            ),
          )
        ],
      ),
      margin: const EdgeInsets.all(16),
    );
  }

  static Widget BuildSearchMaterialInput({ Function onChange} ) {
   
    var searchInput = TextField(
      decoration: InputDecoration(
                              fillColor: RandomColor(),
                              border: OutlineInputBorder(
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8))),
                              focusColor: RandomDarkColor(),
                              labelText: 'search',
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: RandomColor()),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.white),
                              )),
      onChanged: onChange,
    );
     return Container(
      child: searchInput,
      height: 60,
      margin: const EdgeInsets.all(4),
    );
  }
}
