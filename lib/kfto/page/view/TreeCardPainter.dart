import 'dart:math';

import 'package:denkuitop/kfto/data/KftodoListData.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/material.dart';

class ItemPair {
  ListItemData item;
  List<Offset> positions = [];
  double lastRange = 0;
}

class AccPair {
  Offset acc;
  Color color;
  bool hasEdge;
  bool show = false;
}

class Edge {
  Offset x;
  Offset y;
  Color color;
  TreeCardNode nodeX;
  TreeCardNode nodeY;
  bool isHovering = false;
  Offset get middle {
    var a = x - y;
    if (a.dx.abs() > a.dy.abs()) {
      return (x + y) / 2 + Offset(0, 30);
    } else {
      return (x + y) / 2 + Offset(30, 0);
    }
  }
}

class TreeCardNode {
  Offset postion = Offset.zero;
  Color color = Colors.limeAccent;

  bool get hasEdge {
    return edgeSize >= maxEdgeSize - 1;
  }

  int maxEdgeSize = 10;
  int edgeSize = 0;

  bool isShow = true;
  bool isOnHover = false;
  bool isLinked = false;
  List<AccPair> accs = [];
  Offset get acc {
    var tempO = Offset.zero;
    accs.forEach((element) {
      tempO += element.acc;
    });
    return tempO;
  }

  double get weight {
    return item.tags.length.toDouble();
  }

  ListItemData item = null;

  void onHover() {
    isShow = false;
    isOnHover = true;
  }
}

class TreeCardData {
  ListData data;
  List<KfToDoTagData> dataTags = [];
  List<TreeCardNode> nodes = [];
  List<Edge> edges = [];

  bool is_darging_tree_card = false;
  
  bool isDarkmode;

  TreeCardData({ListData data, List<KfToDoTagData> dataTags}) {
    this.data = data;
    this.dataTags = dataTags;
  }

  double distanceMin = 110;
  double distanceMax = 120;

  double maxAccValue = 200;
  double maxAccShortValue = 200;
  Size size = Size(400, 500);
  bool hasSetSize = false;

  double paddingX = 100;
  bool hasSetPaddingX = false;
  double calcA(double d, bool hasEdge, double weight) {
    double res = 0;

    double distanceMaxCalc = distanceMax * (1 + (weight / 10));
    double distanceMinCalc = distanceMin + (20 * (weight * 2));
    if (d < distanceMin) {
      // if (hasEdge) {
      //   res = -1 * d * d * (distanceMin - d).abs() * d / ((d * 2));
      // } else {
        // res = (d - distanceMin) / d;
      // }
      res = (d - distanceMin) ;
      if (hasEdge) {
        res = res * 1.1;
      } 
    } else if (d >= distanceMinCalc && d <= distanceMaxCalc) {
      res = 0;
    } else if (d > distanceMaxCalc) {
      if (hasEdge) {
        res = (d - distanceMaxCalc); //* (d- distanceMax) * -1;
      }
    }
    // res = res * Random().nextInt(3);
    if (res > maxAccValue) {
      res = maxAccValue;
    }
    if (res < -maxAccShortValue) {
      res = -maxAccShortValue;
    }
    if (res.isNaN) {
      print("isNaN ${d} ");
    }
    return res;
  }

  void setPaddingX(double x) {
    if (!hasSetPaddingX) {
      paddingX = x;
      hasSetPaddingX = true;
    }
  }

  void setCanvasSize(Size size) {
    if (!hasSetSize) {
      this.size = size;
      hasSetSize = true;
    }
  }

  bool innerCalc() {
    bool hasChange = false;
    if (this.data != null) {
      var tagList = dataTags; //[dataTags[1], dataTags[0]];
      nodes.forEach((node) {
        if (node.acc.distance > 0) {
          hasChange = true;
        }
        if (shouldReCalc()) {
          node.postion = node.postion + node.acc / 10;
        }

        node.accs = [];
        node.edgeSize = 0;
      });
      edges = [];

      // 1. 随机所有节点的位置
      if (nodes.length == 0 && this.dataTags.length > 0 && hasSetSize) {
        // print("randomw");
        this.data.data.forEach((element) {
          TreeCardNode node = TreeCardNode();
          if (isDarkmode) {
            node.color = dataTags
                .where((tag) {
                  return element.tags.contains(tag.name);
                })
                .first
                .darkColor
                .withAlpha(255);

          } else {

            node.color = dataTags
                .where((tag) {
                  return element.tags.contains(tag.name);
                })
                .first
                .lightColor
                .withAlpha(255);
          }

          node.postion = Offset(
              new Random()
                      .nextInt(size.width.toInt() - paddingX.toInt())
                      .toDouble() +
                  paddingX,
              new Random().nextInt(size.height.toInt()).toDouble());
          node.item = element;
          if (tagList.where((tag) {
                return element.tags.contains(tag.name);
              }).length >
              0) {
            nodes.add(node);
          }
        });

        nodes.sort((a, b) {
          return (a.postion - Offset(size.width / 2, size.height / 2))
                  .distance
                  .toInt() -
              (b.postion - Offset(size.width / 2, size.height / 2))
                  .distance
                  .toInt();
        });
      }

      // 2. 计算所有节点的加速度
      for (int x = 0; x < nodes.length; x++) {
        TreeCardNode nx = nodes[x];

        if (nx.postion.dx < 100 + paddingX) {
          AccPair boderAcc = AccPair();
          boderAcc.acc = Offset(((10 + paddingX) - nx.postion.dx), 0);
          boderAcc.color = nx.color;
          // boderAcc.show = true;
          nx.accs.add(boderAcc);
        }
        if (nx.postion.dy < 10) {
          AccPair boderAcc = AccPair();
          boderAcc.acc = Offset(0, 10);
          boderAcc.color = nx.color;
          // boderAcc.show = true;
          nx.accs.add(boderAcc);
        }

        if (nx.postion.dy > (size.height) - (10 * nx.weight)) {
          AccPair boderAcc = AccPair();
          boderAcc.acc = Offset(0, -10);
          boderAcc.color = nx.color;
          // boderAcc.show = true;
          nx.accs.add(boderAcc);
        }

        if (nx.postion.dx > (size.width ) - (10 * nx.weight)) {
          AccPair boderAcc = AccPair();
          boderAcc.acc = Offset((size.width - nx.postion.dx), 0);
          boderAcc.color = nx.color;
          // boderAcc.show = true;
          nx.accs.add(boderAcc);
        }

        for (int y = x + 1; y < nodes.length; y++) {
          TreeCardNode ny = nodes[y];

          // 是否在同一个tags
          bool hasEdge = nx.item.tags.where((taga) {
                    return ny.item.tags.where((tagb) {
                          return tagb == taga;
                        }).length >
                        0;
                  }).length >
                  0 &&
              !nx.hasEdge &&
              !ny.hasEdge;
          // print("${x} ${y} ${nx.item.tags} ${ny.item.tags} ${hasrEdge} ${nx.hasEdge} ${ny.hasEdge} ${edges.length}");
          Offset yx = nx.postion - ny.postion;
          Offset xy = ny.postion - nx.postion;

          double d = xy.distance;
          yx = Offset(yx.dx / yx.distance, yx.dy / yx.distance);
          xy = Offset(xy.dx / xy.distance, xy.dy / xy.distance);

          AccPair xypair = AccPair();
          xypair.acc = xy * calcA(d, hasEdge, nx.weight + ny.weight);
          xypair.color = ny.color; //.withAlpha(255);
          xypair.hasEdge = hasEdge;
          // xypair.show = true;
          AccPair yxpair = AccPair();
          yxpair.acc = yx * calcA(d, hasEdge, nx.weight + ny.weight);
          yxpair.color = nx.color; //.withAlpha(255);
          yxpair.hasEdge = hasEdge;
          // yxpair.show = true;
          nx.accs.add(xypair);
          ny.accs.add(yxpair);

          Edge edge = new Edge();
          edge.x = nx.postion;
          edge.nodeX = nx;
          edge.y = ny.postion;
          edge.nodeY = ny;
          edge.color = nx.color;
          if (hasEdge) {
            edges.add(edge);
            nx.edgeSize++;
            // nodes[y].hasEdge = hasEdge;
          }
        }
      }
    } else {
      print("this.data is null");
    }
    // print("innerCalc ${hasChange}");
    return hasChange;
  }

  bool shouldReCalc() {
    return this.is_darging_tree_card;
  }

  bool calc() {
    var hasChange = innerCalc();
    innerCalc();
    innerCalc();
    innerCalc();
    innerCalc();
    innerCalc();
    var size = 0;
    // while(hasChange = innerCalc() && size++ < 100);
    // print("calc end ${size}");
    return hasChange;
  }
}

class TreeCardPainter extends CustomPainter {
  TreeCardData data;

  List<KfToDoTagData> dataTags = [];
  Map<String, ItemPair> itemPairs = new Map();
  Offset offset = Offset.zero;
  Offset mouseOffset = Offset.zero;
  List<Offset> pos = [];
  GlobalKey customKey;
  bool isDraging = false;

  Offset position;
  bool isDarkmode = false;
  TreeCardPainter(TreeCardData data,
      {Offset offset,
      List<KfToDoTagData> dataTags,
      bool isDraging = false,
      Offset mouseOffset,
      GlobalKey customKey, bool isDarkmode}) {
    this.data = data;
    this.offset = offset;
    this.dataTags = dataTags;
    this.isDraging = isDraging;
    this.mouseOffset = mouseOffset;
    this.customKey = customKey;
    this.isDarkmode = isDarkmode;
    this.data.isDarkmode = isDarkmode;
  }

  Offset relativePosition() {
    var size = customKey.currentContext.findRenderObject().paintBounds;
    RenderObject renderObject = customKey.currentContext.findRenderObject();
    RenderBox box = renderObject as RenderBox;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      this.position = position;
    }

    return this.mouseOffset - this.position;
  }

  Color getColorFrom(Color color, {bool isAlpha = false}) {
    if (isAlpha) {
      return color.withAlpha(50);
    } else {
      return color.withAlpha(255);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    this.data.setCanvasSize(size);

    data.calc();

    Paint paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    if (isDraging) {
      paint.style = PaintingStyle.stroke;
      paint.color = ViewBuilder.RandomColor();
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
    }
    paint.style = PaintingStyle.fill;

    var isHovering = false;
    var nodes = data.nodes;
    isHovering = nodes.where((node) {
          return node.isOnHover;
        }).length >
        0;
    // this.itemPairs = new Map();

    TreeCardNode hoverNode = null;
    nodes.forEach((node) {
      if ((relativePosition() - node.postion).distance < 10 * node.weight) {
        node.onHover();
        hoverNode = node;
      } else {
        node.isShow = true;
        node.isOnHover = false;
        node.isLinked = false;
      }
    });

    var hoverEdges = data.edges.where((edge) {
      if (hoverNode == null) {
        return false;
      }
      return edge.nodeX == hoverNode || edge.nodeY == hoverNode;
    });

    hoverEdges.forEach((edge) {
      edge.isHovering = true;
      edge.nodeX.isLinked = true;
      edge.nodeY.isLinked = true;
    });

    // draw line
    data.edges.forEach((edge) {
      paint.color =
          getColorFrom(edge.color, isAlpha: isHovering && !edge.isHovering);
      paint.strokeWidth = 1;
      // canvas.drawLine(edge.x, edge.y, paint);
      Path pathP = Path();
      pathP.moveTo(edge.x.dx, edge.x.dy);
      pathP.quadraticBezierTo(
          edge.middle.dx, edge.middle.dy, edge.y.dx, edge.y.dy);
      paint.style = PaintingStyle.stroke;
      canvas.drawPath(pathP, paint);
    });

    canvas.drawCircle(relativePosition(), 10, paint);

    nodes.forEach((node) {
      if (node.isShow || true) {
        paint.color = getColorFrom(node.color,
            isAlpha: (!node.isOnHover && isHovering && !node.isLinked));
        paint.style = PaintingStyle.fill;
        canvas.drawCircle(node.postion, 9 * node.weight, paint);
      }
    });
    nodes.forEach((node) {
      var tempOff = Offset.zero;
      node.accs.forEach((acc) {
        // var oldOff = tempOff;
        tempOff = tempOff + acc.acc;
        // paint.strokeWidth = 1;
        if (acc.show) {
          paint.color =
              getColorFrom(acc.color, isAlpha: isHovering && node.isOnHover);
          canvas.drawLine(node.postion, node.postion + (acc.acc * 3), paint);
          // canvas.drawCircle(node.postion + tempOff, 5, paint);
        }
      });
      // paint.strokeWidth = 4;
      // paint.color = node.color;
      // canvas.drawCircle(tempOff, 3, paint);
    });

    // lay text
    nodes.forEach((node) {
      if (node.isOnHover || node.isLinked) {
        var textPainter = TextPainter(
          text: TextSpan(
              text: node.item.title,
              style: TextStyle(
                  color: getColorFrom(node.color,
                      isAlpha: !node.isOnHover && !node.isLinked))),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width, minWidth: 0);
        var maxTextWidth = textPainter.size
            .width; // > maxTextWidth ? textPainter.size.width : maxTextWidth;

        paint.color = getColorFrom(Colors.white,
            isAlpha: !node.isOnHover && !node.isLinked);
        canvas.drawRect(
            Rect.fromPoints(
                node.postion,
                node.postion +
                    Offset(textPainter.size.width, textPainter.size.height)),
            paint);
        textPainter..paint(canvas, node.postion);
      }
    });

    // lay left bar

    Offset cardSize = Offset(20, 20);
    Offset paddingSize = Offset(10, 10);
    double paddingY = size.height * 0.1;
    Offset lt = Offset(0, paddingY) + paddingSize;
    Offset rb = lt + cardSize;
    double paddingX = 0;
    double maxTextWidth = 0;
    this.dataTags.forEach((tag) {
      paint.color = this.getColorFromTag(tag);
      canvas.drawRect(Rect.fromPoints(lt, rb), paint);

      var textPainter = TextPainter(
        text: TextSpan(text: tag.name, style: TextStyle(color: paint.color)),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: size.width, minWidth: 0);
      textPainter..paint(canvas, lt + Offset(30, 0));

      maxTextWidth = textPainter.size.width > maxTextWidth
          ? textPainter.size.width
          : maxTextWidth;

      if (rb.dy > size.height * 0.9) {
        paddingX += 30 + 50;
        rb = Offset(rb.dx, paddingY);
      }

      lt = Offset(paddingX, rb.dy) + paddingSize;
      rb = lt + cardSize;
    });

    this.data.setPaddingX(paddingX + maxTextWidth);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    // var res = nodes.where((element) => (element.acc.distance > 1)).length > 0;;
    // print("shouldRepaint ${res}");

    return this.data != null &&
        this
            .data
            .calc(); // true;// this.nodes.where((element) => (element.acc.distance > 10)).length > 0;
  }

  Color getColorFromTag(KfToDoTagData tagData) {
    return isDarkmode ? tagData.lightColor.withAlpha(255) : tagData.lightColor.withAlpha(255);
  }
}
