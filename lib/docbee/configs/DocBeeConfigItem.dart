import 'dart:ffi';
import 'dart:math';
import 'package:stack/stack.dart';

enum DocBeeConfigItemType { Float, Switch, Compute,Int }

class DocBeeConfigItem {
  int id;
  DocBeeConfigItemType type;
  dynamic value;
  String name;
  String desc;
  String errorText;
  String name1 = '';
  String name2 = '';
  Function getValue = null;
  List<DocBeeConfigItem> depItems = [];
}

// class DocBeeConfigSwitchItem extends DocBeeConfigItem {
//   String name1 = '';
//   String name2 = '';
// }

class DocBeeConfigList {
  List<DocBeeConfigItem> items = [];
  static int allIdCounts = 0;
  String computeText = '';
  DocBeeConfigList() {}

  List<String> computeItems =[];

  Map<String,dynamic> results = new Map();

  String resultText = '';
  List<String> resultTexts = [];
  splitTextAsComputeItem() {
    computeItems = [];
    resultText = '';
    resultTexts = [];
    int pos = 0;
    Stack<int> posStack = Stack<int>();
    while(pos < computeText.length) {
      // print('${computeText.substring(pos,pos+1)}');
      if (computeText.substring(pos,pos+1) == '(') {
        posStack.push(pos);
      } else if (computeText.substring(pos,pos+1) == ')') {
        int startPos = posStack.pop();
        computeItems.add(computeText.substring(startPos,pos+1));
      }
      pos++;
    }
    print('computeItems ${computeItems} ${posStack.length} ${computeText.length}');
  }

  String getUsefullArg (String element) {
    if (element.startsWith('(') && element.endsWith(')')) {
      element = element.substring(1, element.length -1);
    }

    return element;
  }

  dynamic getValueByArg(String arg) {
    if (results.containsKey(arg)) {
      return results[arg];
    } else {
      try {
        return double.parse(arg);
      } catch(err) {
         var item1 = items.firstWhere((item) => item.name == arg, orElse: () {
          return null;
        });
        if (item1 == null) {
          throw err;
        } else {
          
            if (item1.type == DocBeeConfigItemType.Compute) {
              return item1.getValue();
            } else {
              return item1.value;
            }
        }
      }
    }
  }

  dynamic getValueFromItem(DocBeeConfigItem item,String arg) {
    if (item == null) {
      return getValueByArg(arg);
    }
    if (item.type == DocBeeConfigItemType.Compute) {
      return item.getValue();
    } else {
      return item.value;
    }
  }

  void calcSingle(String element, String op, { Function doCalc}) {
    if (element.indexOf(op) > 0) {
      print("start ${op} ${element}");
      var els = element.split(op);
      var arg1 = els[0];
      arg1 = getUsefullArg(arg1);
      var arg2 = els[1];
      arg2 = getUsefullArg(arg2);
      var item1 = items.firstWhere((item) => item.name == arg1, orElse: () {
        return null;
      });
      
      var item2 = items.firstWhere((item) => item.name == arg2, orElse: () => null);



      var value1 = getValueFromItem(item1,arg1);
      var value2 = getValueFromItem(item2,arg2);
      // var res = value1 / value2;
      var res = doCalc(value1, value2);
      results[element] = res;
      resultTexts.add( '${element} => ${value1}${op}${value2} = ${res}');
      print('${element} => ${value1}${op}${value2} = ${res}');
    }
  }

  String doSimpleCalc(String text) {
    List<String> ops = ['/','*','+','^','d'];
    int minPos = 99999;
    ops.forEach((op) {
      var pos = text.indexOf(op);
      if (pos != -1) {

        minPos = min(pos,minPos);
      }
      // print("indexOf ${op} ${pos} ${minPos}");
    });
      print("doSimpleCalc minPos ${minPos}");
    if (minPos == 99999 ) {
      print("doSimpleCalc return ${text}");
      return text;
    }
    var v1t = text.substring(0, minPos);
    var op = text.substring(minPos, minPos+1);
    var v2t = text.substring(minPos+1);
    v2t = doSimpleCalc(v2t);
    v1t = getUsefullArg(v1t);
    v2t = getUsefullArg(v2t);
    var v1 = getValueByArg(v1t);
    var v2 = getValueByArg(v2t);
    var res = 0.0;
    if (op == '*') {
      res = v1 * v2;
    }
    if (op == '/') {
      res = v1 / v2;
    }

    if (op == '+') {
      res = v1 + v2;
    }

    if (op == 'd') {
      res = v1 - v2;
    }
    if (op == '^') {
      res = pow(v1,v2);
    }
    print("doSimpleCalc ${v1t}${op}${v2t} = ${res}");
    resultTexts.add( '${v1t}${op}${v2t} = ${res}');
    return res.toString();
  }

  String calc() {
    results = new Map();
    resultText = '';
    resultTexts = [];
    var computeTextCalc = computeText;
    resultTexts.add( '${computeText} ');
    computeItems.forEach((element) { 
      
      element = getUsefullArg(element);
      results.keys.forEach((resItem) { 
        element = element.replaceAll(resItem, getValueByArg(resItem).toString());
      });
      calcSingle(element, '/', doCalc:(v1, v2) {
        var r =  v1/v2;
        computeTextCalc = computeTextCalc.replaceAll(element, r.toString());
        return r;
      });

      calcSingle(element, '^', doCalc: (v1,v2) {
        var r =  pow(v1, v2);
        computeTextCalc = computeTextCalc.replaceAll(element, r.toString());
        return r;
      });
      calcSingle(element, '*', doCalc: (v1,v2) {
        var r =  v1 * v2;
        computeTextCalc = computeTextCalc.replaceAll(element, r.toString());
        return r;
      });

     
      print('calc ${element} ');
    });
    print('calc result ${results} ${computeTextCalc}');
    resultTexts.add( '${computeTextCalc} ');
    var res = doSimpleCalc(computeTextCalc);
    resultTexts.add( '${res}');
    resultText = res;
    return res;
  }

  static DocBeeConfigList buildLists() {
    var eGFRConfig = DocBeeConfigList();
    eGFRConfig.computeText = '135*((Scr/A)^B)*((Scys/C)^D)*(0.9961^Age)*E';
    var itemScr = DocBeeConfigItem();
    itemScr.type = DocBeeConfigItemType.Float;
    itemScr.name = 'Scr';
    itemScr.id = DocBeeConfigList.allIdCounts++;
    itemScr.value = 0;
    var itemScys = DocBeeConfigItem();
    itemScys.type = DocBeeConfigItemType.Float;
    itemScys.name = 'Scys';
    itemScys.id = DocBeeConfigList.allIdCounts++;
    itemScys.value = 0;
    var itemGender = DocBeeConfigItem();
    itemGender.type = DocBeeConfigItemType.Switch;
    itemGender.name = 'Gender';
    itemGender.id = DocBeeConfigList.allIdCounts++;
    itemGender.name1 = 'Man';
    itemGender.name2 = 'Woman';
    itemGender.value = 0;
    var itemAge = DocBeeConfigItem();
    itemAge.type = DocBeeConfigItemType.Int;
    itemAge.name = 'Age';
    itemAge.id = DocBeeConfigList.allIdCounts++;
    itemAge.value = 0;
    var itemA = DocBeeConfigItem();
    itemA.type = DocBeeConfigItemType.Compute;
    itemA.name = 'A';
    itemA.getValue = () {
      if ((itemGender.value as int) == 0) {
        return 0.9;
      } else {
        return 0.7;
      }
    };
    var itemE = DocBeeConfigItem();
    itemE.type = DocBeeConfigItemType.Compute;
    itemE.name = 'E';
    itemE.getValue = () {
      print("getVlaue for ${itemE.name}");
      return (itemGender.value as int) == 0 ? 1 : 0.963;
    };
    var itemB = DocBeeConfigItem();
    itemB.type = DocBeeConfigItemType.Compute;
    itemB.name = 'B';
    itemB.getValue = () {
      if ((itemGender.value as int) == 0) {
        if (itemScr.value <= 0.9) {
          return -0.144;
        } else {
          return -0.544;
        }
      } else {
        if (itemScr.value <= 0.7) {
          return -0.219;
        } else {
          return -0.544;
        }
      }
    };
    var itemC = DocBeeConfigItem();
    itemC.type = DocBeeConfigItemType.Compute;
    itemC.name = 'C';
    itemC.getValue = () {
      return 0.8;
    };
    var itemD = DocBeeConfigItem();
    itemD.type = DocBeeConfigItemType.Compute;
    itemD.name = 'D';
    itemD.getValue = () {
      if (itemScys.value <= 0.8) {
        return -0.323;
      } else {
        return -0.778;
      }
    };
    

    eGFRConfig.items.add(itemScr);
    eGFRConfig.items.add(itemScys);
    eGFRConfig.items.add(itemGender);
    eGFRConfig.items.add(itemAge);
    eGFRConfig.items.add(itemE);
    eGFRConfig.items.add(itemA);
    eGFRConfig.items.add(itemB);
    eGFRConfig.items.add(itemC);
    eGFRConfig.items.add(itemD);


    eGFRConfig.splitTextAsComputeItem();
    return eGFRConfig;
  }
}
