import 'package:denkuitop/docbee/configs/DocBeeConfigItem.dart';
import 'package:denkuitop/remote/base/BaseRemotePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DocBeeHomePage extends BaseRemotePage {
  @override
  BaseRemotePageState createState() {
    return DocBeeHomeState();
  }
}

class DocBeeHomeState extends BaseRemotePageState {
  DocBeeHomeState() {}

  DocBeeConfigList dataLists = DocBeeConfigList.buildLists();
  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [];
    dataLists.items.forEach((item) {
      if (item.type == DocBeeConfigItemType.Float) {
        childs.add(TextFormField(
          cursorColor: Theme.of(context).cursorColor,
          initialValue: '',
          // maxLength: 20,
          decoration: InputDecoration(
              icon: Icon(Icons.favorite),
              labelText: item.name,
              helperText: 'Help text is empty',
              suffixIcon: null,
              errorText: item.errorText
              // suffixIcon: Icon(
              //   Icons.check_circle,
              // ),
              ),
          onChanged: (value) {
            dataLists.items.where((element) {
              return element.id == item.id;
            }).forEach((element) {
              try {
                var vaildValue = double.parse(value);
                item.errorText = null;
                setState(() {
                  element.value = vaildValue;
                });
              } catch (err) {
                setState(() {
                  item.errorText = 'Please enter float';
                });
              }
            });
          },
        ));
      } else if (item.type == DocBeeConfigItemType.Switch) {
        childs.add(Column(
          children: [
            Text(item.name),
            Row(children: [
              Checkbox(
                onChanged: (bool value) {
                  setState(() {
                    item.value = 0;
                  });
                },
                value: item.value == 0,
                activeColor: Color(0xFF6200EE),
              ),
              Text(item.name1),
              Checkbox(
                onChanged: (bool value) {
                  setState(() {
                    item.value = 1;
                  });
                },
                value: item.value == 1,
                activeColor: Color(0xFF6200EE),
              ),
              Text(item.name2),
            ])
          ],
        ));
      }
    });

    childs.add(Text("All Params"));
    dataLists.items.forEach((item) {
      if (item.type == DocBeeConfigItemType.Compute) {
        print("render type computed ${item.name}");
        childs.add(Text(
            item.name + ' computed result is: ' + item.getValue().toString()));
      } else {
        childs.add(Text(item.name + ' is: ' + item.value.toString()));
      }
    });

    return Card(
      child: Column(children: [...childs]),
    );
  }
}
