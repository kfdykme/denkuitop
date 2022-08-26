

import 'dart:ui';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/material.dart';


class ColorPair {
  Color colorL;
  Color colorD;
  ColorPair(Color colorLight, Color colorDark) {
    colorL = colorLight;
    colorD = colorDark;
  }

  Color Get() {
    return ColorManager.instance().isDarkmode ? colorD : colorL;
  }
}
class ColorManager  {
  static ColorManager _is;
  
  Map<String,ColorPair> colors = new Map();
  static ColorManager instance() {
    if (_is == null) {
     _is = ColorManager();
    } 
    return _is;
  }

  ColorManager() {
    colors['cardbackground'] = new ColorPair(Colors.white, Color(0xff333333));
    colors['fontdark'] = new ColorPair(Color(0xaaffffff), Color(0xaa333333));
    colors['font'] = new ColorPair( Color(0xff333333), Color(0xffffffff));
    colors['background'] = new ColorPair(Color(0xefefefef), Color(0xff000000));
    colors['textr'] = new ColorPair(ViewBuilder.RandomColor(), ViewBuilder.RandomDarkColor());
    colors['snackbackground'] = new ColorPair(ViewBuilder.RandomColor(), ViewBuilder.RandomDarkColor());
    colors['buttonbackground'] = new ColorPair(ViewBuilder.RandomColor().withOpacity(0.3), ViewBuilder.RandomDarkColor().withOpacity(0.3));
    
    colors['buttontext'] = new ColorPair(ViewBuilder.RandomDarkColor(), ViewBuilder.RandomColor());
    colors['textdarkr'] = new ColorPair(ViewBuilder.RandomDarkColor(), ViewBuilder.RandomColor());
    colors['taglightcolor'] = new ColorPair(ViewBuilder.RandomDarkColor(), ViewBuilder.RandomColor());
    colors['taglightcolor2'] = new ColorPair(ViewBuilder.RandomDarkColor(), ViewBuilder.RandomColor());
    colors['tagdarkcolor'] = new ColorPair(ViewBuilder.RandomColor(), ViewBuilder.RandomDarkColor());
    colors['tagdarkcolor2'] = new ColorPair(ViewBuilder.RandomColor(), ViewBuilder.RandomDarkColor());
    colors['tagtextfielddark'] = new ColorPair(ViewBuilder.RandomDarkColor(), ViewBuilder.RandomColor());
    colors['tagtextfieldlight'] = new ColorPair(ViewBuilder.RandomColor(), ViewBuilder.RandomDarkColor());
  }

  bool isDarkmode = false;


  static Color highLightColor =  Color(0xFF6200EE);

  static Color Get(String s) {
    var ins = instance();
    s = s.toLowerCase();
    var res =  ins.colors[s];
    if (res == null) {
      print("ColorManager get ${s} color fail");
      return  Colors.amberAccent;
    }
    return res.Get();
  }
  
}