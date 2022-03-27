import 'package:flutter/material.dart';

var lastSnackBar = null;
ShowSnackBarText(BuildContext context, String text) {
  if (lastSnackBar != null) {
    Scaffold.of(context).removeCurrentSnackBar();
    lastSnackBar = null;
  }
  lastSnackBar = new SnackBar(
    content: new Text(text),
  );
  Scaffold.of(context).showSnackBar(lastSnackBar);
}
