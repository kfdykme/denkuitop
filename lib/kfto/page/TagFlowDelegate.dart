import 'package:flutter/cupertino.dart';

class TagFlowDelegate extends FlowDelegate {

  @override
  Size getSize(BoxConstraints constraints) {
    // TODO: implement getSize
    return BoxConstraints(maxHeight: 50.0).biggest;
  }
  @override
  void paintChildren(FlowPaintingContext context) {
    // TODO: implement paintChildren
    var width = context.size.width;

    const itemMaxWidth = 100;
    double padding = 5;
    double offsetX = padding;
    double offsetY = padding;

    int y = 0;
    int x = 0;
    for (int i = 0; i < context.childCount; i++) {
      var size = context.getChildSize(i);
      if (offsetX + itemMaxWidth + size.width < width) {
        context.paintChild(i,
            transform: Matrix4.translationValues(offsetX, offsetY, 0));
        offsetX = offsetX + size.width + padding;
      } else {
        context.paintChild(i,
            transform: Matrix4.translationValues(offsetX, offsetY, 0));
        offsetX = padding;
        offsetY = offsetY + 500 + padding;

      }
    }
  }

  @override
  bool shouldRepaint(covariant FlowDelegate oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}
