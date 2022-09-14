import 'dart:math';

import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/material.dart';

double DrawText(
  Canvas canvas,
  Offset position,
  String text, {
  Color color = Colors.amberAccent,
  double maxWidth = 100,
}) {
  double textWidth = 0;
  if (text == null) {
    text = "";
  }

  var c = 1;
  while (c * c < text.length) {
    c++;
  }
  var textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: color, fontSize: maxWidth / (c * 2)),
      ),
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: maxWidth);

  textWidth = textPainter.size.width;
  textPainter.paint(canvas, position);
  return textWidth;
  // return textPainter.size.width;
}

class GridCardNode {
  MaterialAccentColor borderColor;

  bool isShowBorder;

  Color color;

  Offset ori;

  Offset end;

  ListItemData item;
}

class GridCardData {
  List<ListItemData> data;

  int count = 0;
  double width = 0;
  double height = 0;
  double tilsWidth = 10;
  double tilsHeight = 10;
  Offset cardSize = Offset.zero;
  Size size;

  List<List<GridCardNode>> nodemaps = [[]];

  List<KfToDoTagData> tags;

  bool isInited = false;

  int lastLength = 0;
  void init() {
    // get row & col count
    if (lastLength == this.data.length) {
      return;
    }
    print("init");
    int count = 1;
    while (count * count < this.data.length) {
      count++;
    }
    lastLength = this.data.length;
    nodemaps = [[]];
    this.count = count;
    tilsWidth = width / this.count;
    tilsHeight = height / this.count;

    if (tilsWidth > 120) {
      tilsWidth = 60;
    }
    if (tilsHeight > 120) {
      tilsHeight = 60;
    }
    cardSize = Offset(tilsWidth * 0.8, tilsHeight * 0.8);

    for (int x = 0; x < count; x++) {
      List<GridCardNode> rows = [];
      for (int y = 0; y < count; y++) {
        Offset ori = Offset(x * tilsWidth, y * tilsHeight);
        GridCardNode cardNode = GridCardNode();

        var index = x * count + y;
        if (index < data.length) {
          var node = data[index];

          cardNode.borderColor = Colors.amberAccent;
          cardNode.isShowBorder = false;

          cardNode.ori = ori;
          cardNode.end = ori + cardSize;
          cardNode.item = node;
          rows.add(cardNode);
        }
      }
      nodemaps.add(rows);
    }
    isInited = true;
  }

  void setCanvasSize(Size size) {
    this.size = size;
    this.width = size.width;
    this.height = size.height;

    init();
  }

  void setData(List<ListItemData> data, List<KfToDoTagData> tags) {
    if (data == null) {
      print("setData null");
      return;
    }
    this.data =
        List.from(data.where((element) => element.type.contains("normal")));
    this.tags = tags;
  }

  void refreshColor(GridCardNode node) {
    var targetTag = this.tags.where((tag) {
      return node.item.tags.contains(tag.name);
    }).first;
    if (ColorManager.instance().isDarkmode) {
      node.color = targetTag.lightColor;
    } else {
      node.color = targetTag.darkColor2;
    }
  }
}

class GridCardPainter extends CustomPainter {
  ValueNotifier<int> dataLength;
  bool hasInitedSize = false;

  GridCardData gridCardData;
  GridCardPainter(this.dataLength) {}

  @override
  void paint(Canvas canvas, Size size) {
    // if (!hasInitedSize) {
    //   return;
    // }
    this.gridCardData.setCanvasSize(size);

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    if (!gridCardData.isInited) {
      return;
    }
    canvas.translate(100, 0);
    for (int x = 0; x < gridCardData.count; x++) {
      for (int y = 0; y < gridCardData.count; y++) {
        var row = gridCardData.nodemaps[x];
        if (row.length == 0) {
          continue;
        }
        var node = row[y];

        if (node != null) {
          paint.style = PaintingStyle.stroke;
          paint.color = node.borderColor;
          canvas.drawRect(Rect.fromPoints(node.ori, node.end), paint);
          paint.style = PaintingStyle.fill;

          gridCardData.refreshColor(node);
          paint.color = node.color;
          canvas.drawRect(Rect.fromPoints(node.ori, node.end), paint);
          DrawText(canvas, node.ori + Offset(4, 4), node.item.title,
              maxWidth: gridCardData.cardSize.dx - 8,
              color: ColorManager.Get("font"));

          DrawText(
              canvas,
              node.ori + Offset(4, 4) + Offset(0, gridCardData.cardSize.dy / 2),
              node.item.date,
              maxWidth: gridCardData.cardSize.dx - 8,
              color: ColorManager.Get("fontdark"));
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

  void setPainterData(GridCardData gridCardData) {
    this.gridCardData = gridCardData;
  }
}

class MStack<E> {
  final List<E> _stack;
  int _top;

  int max = 999;

  MStack()
      : _top = -1,
        _stack = List<E>(999);

  bool get isEmpty => _top == -1;
  bool get isFull => _top == max - 1;
  int get size => _top + 1;
  Map<E,bool> marks = new Map();
  void push(E e) {
    if (isFull) return null;
    marks[e] = true;
    _stack[++_top] = e;
  }

  bool has(E e) {
    bool hasRes =  marks.keys.contains(e);
    return hasRes;
  }

  E pop() {
    if (isEmpty) return null;
    marks.remove(e);
    return _stack[_top--];
  }

  E get top {
    if (isEmpty) return null;
    return _stack[_top];
  }
}

class SplitCardData extends GridCardData {
  MStack<Offset> tryNodeMStack = MStack();

  // List<List<int>> maps = [];

  Map<String, int> maps = Map();
  Map<String, ListItemData> itemMaps = Map();

  int lastMaxLength = 0;

  // init nodemaps
  int maxX = 0;
  int maxY = 0;
  
  int tagIndex = 0;

  Offset lastNode = Offset.zero;
  String pos(int x, int y) {
    return Offset(x.toDouble(), y.toDouble()).toString();
  }
  Offset posOffset(int x, int y) {
    return Offset(x.toDouble(), y.toDouble());
  }

  bool get isFull {
    return tagIndex >= filteredTags.length;
  }


  List<KfToDoTagData> get filteredTags {
    if (tags == null ){
      return [];
    }
    return List.from(tags.where((element) => !element.isRss && !element.isRssItem && !element.name.startsWith("_")));
  }

  int  get getTagIndex {
    if (tags == null ) {
      return 0;
    }
    if (tagIndex + 1 > filteredTags.length) {
      tagIndex = 0;
    }
    return tagIndex;
  }

  @override
  void init() {
    if (lastLength == this.data.length) {
      return;
    }
    if (isInited) {
      return;
    }

    // init count
    count = data.length;

    // init maps
    for (int x = 0; x < count; x++) {
      for (int y = 0; y < count; y++) {
        maps[pos(x, y)] = 0;
      }
    }

    // init tryNodeMStack
    if (tryNodeMStack == null || tryNodeMStack.isEmpty) {
      tryNodeMStack = MStack();
      tryNodeMStack.push(Offset(0, 0));
    }

    isInited = true;
  }

  void calcAll() {
    while(tagIndex < filteredTags.length) {
      calc();
    }
  }

  void calc() {

    // forEach tags
    if (filteredTags.length == 0) {
      return;
    }

    if (tagIndex == 0) {
       // init maps
      for (int x = 0; x < count; x++) {
        for (int y = 0; y < count; y++) {
          maps[pos(x, y)] = 0;
        }
      }
      tryNodeMStack = MStack();
      tryNodeMStack.push(Offset(0, 0));
      lastMaxLength = 0;
      maxX = 0;
      maxY = 0;
      // return;
    }

    var tag = filteredTags[getTagIndex];

    tagIndex++;
    {
      // get nodes
      print("tag ${tag}");
      List<ListItemData> items =
          List.from(data.where((node) => node.tags.contains(tag.name)));

      if (items.length <= 0) {
        print("items.length <= 0");
        return;
      }
      // get item count
      int itemCount = 1;
      while (itemCount * itemCount++ < items.length);
      print(items.length);
      //
      Offset block = Offset((--itemCount).toDouble(), itemCount.toDouble());
      
      // mark block in maps

      var cacheMaps = Map.from(maps);
      var currentShortestMap = maps;
      int currentSHortestLength = count;
      Offset ori = Offset.zero;
      var currentShortestOri = ori;
      var currentShortestMaxY = maxY;
      var currentShortestMaxX = maxX;
      var lists = List.from(tryNodeMStack._stack.where((element) => element != null));
      lists.sort((a,b) {
        return ((a.distance-b.distance)* 10) .toInt();
      });
      // while (!tryNodeMStack.isEmpty) {
      // while (!tryNodeMStack.isEmpty) {
      // print("${lists}");
      if (lists.length > 0)
      {
        //  ori= tryNodeMStack.pop();
        ori= lists.first;
        lastNode = ori;
        maps =  Map.from(cacheMaps);


        int itemIndex = 0;
        for (int x = 0; x < block.dx; x++) {
          for (int y = 0; y < block.dy; y++) {
            if (itemIndex < items.length) {
              // maps[x + ori.dx.toInt()][y + ori.dy.toInt()] = 1;
              maps[pos(x + ori.dx.toInt(), y + ori.dy.toInt())] = ColorManager.instance().isDarkmode ? tag.lightColor.value : tag.darkColor2.value;
              itemMaps[pos(x + ori.dx.toInt(), y + ori.dy.toInt())] = items[itemIndex++];
              maxX = max(maxX, x + ori.dx.toInt());
              maxY = max(maxY, y + ori.dy.toInt());
            }
          }
        }
        

          var blockLength = max(maxX, maxY);
          if (blockLength < currentSHortestLength) {
            currentSHortestLength = blockLength;
            currentShortestMap = Map.from(maps);
            currentShortestOri = ori;
            currentShortestMaxX = maxX;
            currentShortestMaxY = maxY;
            lastMaxLength = blockLength;
          }
        
      }
      maps = Map.from(currentShortestMap);
      ori = currentShortestOri;
      maxY = currentShortestMaxY;
      maxX = currentShortestMaxX;

      // get next MStack
      tryNodeMStack = MStack();
      int oriX = 0;
      int oriY = maxY + 1;
      // print("get next MStack ${oriY} ${oriX}");

      while (oriY > 0 && !tryNodeMStack.isFull) {
        // print("while index ${index++} ${tryNodeMStack.top} ${maps[oriX][oriY]} ");
        ori = Offset(oriX.toDouble(), (oriY).toDouble());
        tryNodeMStack.push(ori);
        oriX = ori.dx.toInt();
        oriY = ori.dy.toInt();
        // top
        // if (maps[oriX][oriY - 1] == 0) {
        if (maps[pos(oriX, oriY - 1)] == 0 && !tryNodeMStack.has(posOffset(oriX, oriY -1))) {
          oriY--;
          continue;
        }
        // if (oriX + 1 < maps.length && maps[oriX + 1][oriY] == 0) {
        if (oriX + 1 < maps.length && maps[pos(oriX + 1, oriY)] == 0 && !tryNodeMStack.has(posOffset(oriX +1, oriY))) {
          oriX++;
          continue;
        }
        if (maps[pos(oriX, oriY + 1)] == 0 && !tryNodeMStack.has(posOffset(oriX, oriY +1))) {
          oriY++;
          continue;
        }
      }

      ori = Offset(oriX.toDouble(), (oriY).toDouble());
      tryNodeMStack.push(ori);
    };

    cardSize = Offset(width * .9/ lastMaxLength, height * 0.9/lastMaxLength);
  }
}

class SplitCardPainter extends GridCardPainter {
  SplitCardPainter(ValueNotifier<int> dataLength) : super(dataLength);

  SplitCardData splitCardData;

  @override
  void paint(Canvas canvas, Size size) {
    this.splitCardData.setCanvasSize(size);

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;
    // print("${splitCardData.isInited}");
    if (!splitCardData.isInited) {
      return;
    }


    canvas.translate(100, 10);
    // DrawText(canvas, Offset.zero, splitCardData.getTagIndex.toString());

    // int stackSize = splitCardData.tryNodeMStack.size;
    // int index =0;
    while (!splitCardData.tryNodeMStack.isEmpty) {
      var node = splitCardData.tryNodeMStack.pop();
      // index++;

      var ori = Offset(node.dx * splitCardData.cardSize.dx,
          node.dy * splitCardData.cardSize.dy);
      // paint.style = PaintingStyle.stroke;
      // paint.srtrokeWidth = 10;
      paint.color = ColorManager.highLightColor;//.withAlpha((255 * (stackSize - index/stackSize)).toInt());
      if (splitCardData.maps[splitCardData.pos(node.dx.toInt(), node.dy.toInt())] != 0) {
        paint.color = Colors.redAccent;
        paint.style = PaintingStyle.fill;
      }
      // print("${splitCardData.maps[splitCardData.pos(ori.dx.toInt(), ori.dy.toInt())]} ${ori}");
      // canvas.drawRect(
      //     Rect.fromPoints(ori, ori + splitCardData.cardSize), paint);
    }

   
    // print("${splitCardData.maps}");
    for (int x = 0; x <= splitCardData.lastMaxLength; x++) {
      for (int y = 0; y <= splitCardData.lastMaxLength; y++) {
        var ori = Offset(
            x * splitCardData.cardSize.dx, y * splitCardData.cardSize.dy);
        // if (splitCardData.maps[x][y] != 0) {
        if (splitCardData.maps[splitCardData.pos(x, y)] != 0) {
          paint.style = PaintingStyle.fill;
          paint.color = Color(splitCardData.maps[splitCardData.pos(x, y)]);
        canvas.drawRect(
            Rect.fromPoints(ori, ori + splitCardData.cardSize * 0.8), paint);
        DrawText(canvas, ori + Offset(2, 2),
            splitCardData.itemMaps[splitCardData.pos(x, y)].title,
            maxWidth: splitCardData.cardSize.dx,
            color: ColorManager.Get("font"));
        } 
      }
    }

    //  var ori = Offset(splitCardData.lastNode.dx * splitCardData.cardSize.dx,
    //       splitCardData.lastNode.dy * splitCardData.cardSize.dy);
    // paint.color = Colors.redAccent;
    //     paint.style = PaintingStyle.fill;
    //   canvas.drawRect(
    //       Rect.fromPoints(ori, ori + splitCardData.cardSize), paint);


    // var lists = List.from(splitCardData.tryNodeMStack._stack.where((element) => element != null));
    // lists.sort((a,b) {
    //   return ((a.distance-b.distance)* 10) .toInt();
    // });
    // var ii = 0;
    // lists.forEach((node) {
    //   ii++;
    //  DrawText(canvas, Offset(node.dx * splitCardData.cardSize.dx,
    //       node.dy * splitCardData.cardSize.dy) + Offset(2, 2),
    //         ii.toString(),
    //         maxWidth: splitCardData.cardSize.dx,
    //         color: ColorManager.Get("font"));
    // });
  }

  void setPainterSplitData(SplitCardData gridCardData) {
    // TODO: implement setPainterData
    setPainterData(gridCardData);
    splitCardData = gridCardData;
  }
}
