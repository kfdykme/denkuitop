import 'dart:ffi';

enum DocBeeConfigItemType { Float, Switch, Compute }

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
  DocBeeConfigList() {}
  static DocBeeConfigList buildLists() {
    var eGFRConfig = DocBeeConfigList();

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
    var itemA = DocBeeConfigItem();
    itemA.type = DocBeeConfigItemType.Compute;
    itemA.name = 'A';
    itemA.getValue = () {};
    var itemE = DocBeeConfigItem();
    itemE.type = DocBeeConfigItemType.Compute;
    itemE.name = 'E';
    itemE.getValue = () {
      print("getVlaue for ${itemE.name}");
      return (itemGender.value as int) == 0 ? 1 : 0.963;
    };

    eGFRConfig.items.add(itemScr);
    eGFRConfig.items.add(itemScys);
    eGFRConfig.items.add(itemGender);
    eGFRConfig.items.add(itemE);

    return eGFRConfig;
  }
}
