

import 'dart:ui';

class ColorManager  {
  static ColorManager _is;
  static ColorManager instance() {
    if (_is != null) {
     _is = ColorManager();
    } 
    return _is;
  }

  ColorManager() {

  }


  static Color highLightColor =  Color(0xFF6200EE);
  
}