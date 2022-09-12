import 'dart:math';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:flutter/material.dart';

class ViewBuilder {
  static int RANDOM_COLOR_TOP = 230;
  static int RANDOM_COLOR_BOTTOM = 160;
  static int RANDOM_COLOR_BOTTOM_2 = 100;
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
    return ViewBuilder.RANDOM_COLOR_BOTTOM_2 +
        new Random().nextInt(
            ViewBuilder.RANDOM_COLOR_BOTTOM - ViewBuilder.RANDOM_COLOR_BOTTOM_2);
    // return new Random().nextInt(ViewBuilder.RANDOM_COLOR_BOTTOM);
  }

  static Color RandomColor() {
    return Color.fromARGB(RANDOM_COLOR_TOP, ViewBuilder.RandomColorInt(),
        ViewBuilder.RandomColorInt(), ViewBuilder.RandomColorInt());
  }

  static Color RandomDarkColor() {
    return Color.fromARGB(160, ViewBuilder.RandomColorDartInt(),
        ViewBuilder.RandomColorDartInt(), ViewBuilder.RandomColorDartInt());
  }

  static IconData getIconByTag(String tag) {
    if (tag == "_DENKUISCRIPT") {
      return Icons.javascript;
    }

    return Icons.folder;
  }

  static IconData getIconByTagData(KfToDoTagData tagData) {
    if (tagData.isRss) {
      return Icons.rss_feed;
    }

    if (tagData.isRssItem) {}
    return getIconByTag(tagData.name);
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
                getIconByTagData(tagData),
                color: !ColorManager.instance().isDarkmode ? tagData.darkColor2: tagData.lightColor,
                size: size(3),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(size(1), 0, 0, 0),
                child: Text(
                  tag,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color:  !ColorManager.instance().isDarkmode ?  tagData.darkColor2: tagData.lightColor),
                ),
              ),
            ],
          ),
          Icon(
            tagData.isOpen
                ? Icons.arrow_drop_down_sharp
                : Icons.arrow_left_sharp,
            color: !ColorManager.instance().isDarkmode ? tagData.darkColor : tagData.lightColor2,
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
      margin: EdgeInsets.symmetric(vertical: 2, horizontal: size(1)),
      child: Column(children: tagContainorChilds),
      color:  Color(0x11111111)//!ColorManager.instance().isDarkmode ? tagData.lightColor : tagData.darkColor,
    );
  }

  static Widget BuildSingleTagListItemContainor(ListItemData e,
      {Function onPressFunc,
      Function onLongPressFunc,
      Function rssRefreshFunc}) {
    Widget listItemEndView = null;
    if (e.type == 'rss') {
      listItemEndView = BuildInLineMaterialButton("",
          icon: Icon(
            Icons.refresh,
            color: ColorManager.Get("font"),
            size: size(3),
          ), onPressFunc: () {
        if (rssRefreshFunc != null) {
          rssRefreshFunc();
        }
      });
    } else {
      listItemEndView = Text(
        '@${e.date}',
        style: TextStyle(
            color: ColorManager.Get("fontdark"), overflow: TextOverflow.ellipsis),
      );
    }
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
          color: Color(0x00000000),
          margin: EdgeInsets.all(size(1)),
          padding: EdgeInsets.only(left: size(1)),
          child: Stack(
            alignment: AlignmentDirectional.topStart,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [listItemEndView],
              ),
              
              Text(e.title != null ? e.title : "empty", overflow: TextOverflow.ellipsis, style: TextStyle(color:  ColorManager.Get("font")), textAlign: TextAlign.left, maxLines: 1,)
            ],
          )),
    );
    ;
  }

  static Widget BuildInLineMaterialButton(String text,
      {Function onPressFunc, Color color, Icon icon, bool withText = true}) {
    List<Widget> buttonChildrenItems = [];
    if (icon != null) {
      buttonChildrenItems.add(icon);
    }
    if (withText) {

      buttonChildrenItems.add(Container(
        padding: EdgeInsets.only(left: size(1)),
        child: Text(text),
      ));
    }
    return MaterialButton(
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
    );
  }

  static Widget BuildMaterialButton(String text,
      {Function onPressFunc, Color color, Icon icon, Color backgroundColor = const Color(0xffffff), bool withText = true}) {
    List<Widget> buttonChildrenItems = [];
    if (icon != null) {
      buttonChildrenItems.add(icon);
    }
    if (text != "" && withText) {

      buttonChildrenItems.add(Container(
        padding: EdgeInsets.only(left: size(1)),
        child: Text(text, style: TextStyle(color: color),),
      ));
    }
    return Container(
      // color: backgroundColor == null ? null : ColorManager.Get("buttonbackground") ,
      height: 45,
      child: Row(
        children: [
          Container(
            color: backgroundColor == null ? null : ColorManager.Get("buttontext"),
            width: 5,
          ),
          MaterialButton(
            
            textColor: ColorManager.Get("buttontext"),
            onPressed: () {
              print("BuildMaterialButton Press ${text} ${onPressFunc}");
              if (onPressFunc != null) {
                onPressFunc();
              }
            },
            child: Row(
              children: buttonChildrenItems,
            ),
          ),
        ],
      ),
      margin:  EdgeInsets.all(size(1))
    );
  }

  static Widget BuildSearchMaterialInput({Function onChange}) {
    // var searchInput = TextField(
    //   decoration: InputDecoration(
    //       fillColor: RandomColor(),
    //       border: OutlineInputBorder(
    //           borderRadius: const BorderRadius.all(Radius.circular(8))),
    //       focusColor: RandomDarkColor(),
    //       labelText: 'search',
    //       focusedBorder: OutlineInputBorder(
    //         borderSide: BorderSide(color: RandomColor()),
    //       ),
    //       enabledBorder: OutlineInputBorder(
    //         borderSide: BorderSide(color: Colors.white),
    //       )),
    //   onChanged: onChange,
    // );
    // return Container(
    //   child: searchInput,
    //   height: 60,
    //   margin: const EdgeInsets.all(4),
    // );
    return null;
  }
}
