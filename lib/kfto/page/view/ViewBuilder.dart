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
        new Random().nextInt(ViewBuilder.RANDOM_COLOR_BOTTOM -
            ViewBuilder.RANDOM_COLOR_BOTTOM_2);
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
                color: !ColorManager.instance().isDarkmode
                    ? tagData.darkColor2
                    : tagData.lightColor,
                size: size(3),
              ),
              Container(
                margin: EdgeInsets.fromLTRB(size(1), 0, 0, 0),
                child: Text(
                  tag,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: !ColorManager.instance().isDarkmode
                          ? tagData.darkColor2
                          : tagData.lightColor),
                ),
              ),
            ],
          ),
          Icon(
            tagData.isOpen
                ? Icons.arrow_drop_down_sharp
                : Icons.arrow_left_sharp,
            color: !ColorManager.instance().isDarkmode
                ? tagData.darkColor
                : tagData.lightColor2,
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
        padding: tagData.isOpen ? EdgeInsets.fromLTRB(0,0, ViewBuilder.size(1), ViewBuilder.size(1)) : null,
        child: Column(children: tagContainorChilds),
        color: Color(
            0x11aaaaaa) //!ColorManager.instance().isDarkmode ? tagData.lightColor : tagData.darkColor,
        );
  }

  static Widget BuildSingleTagListItemContainor(ListItemData e,
      {Function onPressFunc,
      Function onLongPressFunc,
      KfToDoTagData tagData,
      Function rssRefreshFunc}) {
    Widget listItemEndView = null;
    if (e.type == 'rss') {
      listItemEndView = BuildInLineMaterialButton("update rss",
          icon: Icon(
            Icons.refresh,
            color: ColorManager.Get("font"),
            size: size(2),
          ), onPressFunc: () {
        if (rssRefreshFunc != null) {
          rssRefreshFunc();
        }
      },
      color:  ColorManager.Get("font"),
      backgroundColor: !ColorManager.instance().isDarkmode
                    ? tagData.darkColor2
                    : tagData.lightColor);
    } else {
      listItemEndView = Text(
        '@${e.date}',
        style: TextStyle(
            color: ColorManager.Get("textr"),
            overflow: TextOverflow.ellipsis),
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
      hoverColor: !ColorManager.instance().isDarkmode
                    ? tagData.darkColor2
                    : tagData.lightColor,
      child: Container(
          width: double.infinity,
          color: Color(0x00000000),
          margin: EdgeInsets.all(size(1)),
          padding: EdgeInsets.only(left: size(1)),
          child: Column(
            // alignment: AlignmentDirectional.topStart,
            crossAxisAlignment:CrossAxisAlignment.start,
            children: [
              Container(
                child: Text(
                e.title != null ? e.title : "",
                overflow: TextOverflow.clip,
                style: TextStyle(color: ColorManager.Get("font")),
                textAlign: TextAlign.left,
              ),),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [listItemEndView],
              ),
            ],
          )),
    );
    ;
  }

  static Widget BuildInLineMaterialButton(String text,
      {Function onPressFunc, Color color, Icon icon, bool withText = true, Color backgroundColor = null}) {
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
    return Tooltip(
        message: "",
        verticalOffset: -8,
        // onTriggered: () {
        //    print("BuildMaterialButton onTriggered ${text} ${onPressFunc}");
        //     if (onPressFunc != null) {
        //       onPressFunc();
        //     }
        // },
        child: MaterialButton(
          textColor: color,
          color: backgroundColor,
          onPressed: () {
            print("BuildMaterialButton Press ${text} ${onPressFunc}");
            if (onPressFunc != null) {
              onPressFunc();
            }
          },
          child: Row(
            children: buttonChildrenItems,
          ),
        ));
  }

  static Widget BuildMaterialButton(String text,
      {Function onPressFunc,
      Color color,
      Icon icon,
      Color backgroundColor = const Color(0xffffff),
      bool isRevert = false,
      bool withText = true}) {
    List<Widget> buttonChildrenItems = [];
    if (icon != null) {
      buttonChildrenItems.add(icon);
    }
    if (text != "" && withText) {
      buttonChildrenItems.add(Container(
        padding: EdgeInsets.only(left: size(1)),
        child: Text(
          text,
          style: TextStyle(color: color),
        ),
      ));
    }


    var alignment = MainAxisAlignment.start;

    if (isRevert) {
      alignment = MainAxisAlignment.end;
    }

    const buttonHeight = 45.0;

    var buttonView = Container(
        color: ColorManager.Get("buttonbackground"),
        height: buttonHeight,
        child: Row(
          mainAxisAlignment: alignment ,
          children: [
            Container(
              color: ColorManager.Get("buttontext"),
              width: 4,
            ),
            MaterialButton(
              textColor: ColorManager.Get("buttontext"),
              height: buttonHeight + 19,
              hoverColor: color != null ? color.withAlpha(20) : ColorManager.Get("buttontext").withAlpha(20) ,
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
        margin: EdgeInsets.all(size(1)));
    if (!withText) {
      return Tooltip(
        message: text,
        verticalOffset: -8,
        child: buttonView,
        // onTriggered: () {
        //   print("BuildMaterialButton Press t ${text} ${onPressFunc}");
        //         if (onPressFunc != null) {
        //           onPressFunc();
        //         }
        // },
      );
    }
    return buttonView;
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
