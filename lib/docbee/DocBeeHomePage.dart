import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/docbee/configs/DocBeeConfigItem.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
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

  // render views 
  Widget renderParams () {

    List<Widget> childs = [];
    childs.add(Row(children: [ViewBuilder.BuildInLineMaterialButton("All Params:",color: ColorManager.Get('font'))],));
    dataLists.items.forEach((item) {
      var text = '- ' + item.name + ' = ' + item.value.toString();
      if (item.type == DocBeeConfigItemType.Compute) {
        text = '+ ' + item.name + ' => ' + item.getValue().toString();
      }
        childs.add(ViewBuilder.BuildInLineMaterialButton(text, color: ColorManager.Get('font')));
    });
    return ViewBuilder.BuildInLineCard(Container(
      padding: EdgeInsets.all(8),
      child:  Column(children: childs,),
    ));
  }

  Widget renderResult() {
     List<Widget> childs = [];


    dataLists.resultTexts.forEach((text) { 

        childs.add(ViewBuilder.BuildLineTextView(text));
    });
    return Card(
      
      shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(1.0),
  ),
      color: ColorManager.Get('cardbackground'),
    child: Container(
      padding: EdgeInsets.all(8),
      child:  Column(children: childs,),
    ),);
  }

  Widget renderTitle() {
      List<Widget> childs = [];
      childs.add(ViewBuilder.BuildLineTextView(dataLists.computeText));
    return ViewBuilder.BuildInLineCard(Container(
      padding: EdgeInsets.all(8),
      child:  Column(children: childs,),
    ));
  }

  Widget renderInput() {
    List<Widget> childs = [];

  dataLists.items.forEach((item) {
      if (item.type == DocBeeConfigItemType.Float) {
        childs.add( Container(padding: EdgeInsets.all(8), child: TextFormField(
          cursorColor: ColorManager.Get('buttontext'),
          initialValue: '',
          // maxLength: 20,
          decoration: InputDecoration(
              // icon: Icon(Icons.favorite),
              labelText: item.name,
              labelStyle: TextStyle(color: ColorManager.Get('font')),
              // helperText: 'Help text is empty',
              suffixIcon: null,
              errorText: item.errorText,
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorManager.Get('taglightcolor')),
              ),
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
        ),));
      } else if (item.type == DocBeeConfigItemType.Int) {
        childs.add(Container(padding: EdgeInsets.all(8),child: TextFormField(
          cursorColor: ColorManager.Get('buttontext'),
          initialValue: '',
          // maxLength: 20,
          decoration: InputDecoration(
              // icon: Icon(Icons.favorite),
              labelText: item.name,
              labelStyle: TextStyle(color: ColorManager.Get('font')),
              helperText: '',
              suffixIcon: null,
              errorText: item.errorText,
              focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: ColorManager.Get('taglightcolor')),
              ),
              // suffixIcon: Icon(
              //   Icons.check_circle,
              // ),
              ),
          onChanged: (value) {
            dataLists.items.where((element) {
              return element.id == item.id;
            }).forEach((element) {
              try {
                var vaildValue = int.parse(value);
                item.errorText = null;
                setState(() {
                  element.value = vaildValue;
                });
              } catch (err) {
                setState(() {
                  item.errorText = 'Please enter int';
                });
              }
            });
          },
        ),));
      } 
      else if (item.type == DocBeeConfigItemType.Switch) {
        childs.add(Column(
          children: [
            ViewBuilder.BuildInLineMaterialButton(item.name, color: ColorManager.Get('font')),
            Row(children: [
              Checkbox(
                onChanged: (bool value) {
                  setState(() {
                    item.value = 0;
                  });
                },
                value: item.value == 0,
                activeColor: ColorManager.Get('taglightcolor'),
              ),
              Text(item.name1,style: TextStyle(color: ColorManager.Get('font')),),
              Checkbox(
                onChanged: (bool value) {
                  setState(() {
                    item.value = 1;
                  });
                },
                value: item.value == 1,
                activeColor:  ColorManager.Get('taglightcolor2'),
              ),
              Text(item.name2, style: TextStyle(color: ColorManager.Get('font'))),
            ])
          ],
        ));
      }
    });
    return Card(
      shape:  RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(1.0),
  ),
      color: ColorManager.Get('cardbackground'),
    child: Container(
      padding: EdgeInsets.all(8),
      child:  Column(children: childs,),
    ),);
  }
  @override
  Widget build(BuildContext context) {
    List<Widget> childs = [];
   
    childs.add(renderTitle());
    childs.add(renderInput());
    childs.add(Row(children: [
      ViewBuilder.BuildMaterialButton("Calc", onPressFunc: (){
      dataLists.calc();
      setState(() {
        
      });
    }, otherChilds: [ViewBuilder.BuildInLineMaterialButton('Result: ${dataLists.resultText}', color: ColorManager.Get('font'))]),
    // 
    ],));

    childs.add(renderParams());
    childs.add(renderResult());
    return Container(
      color: ColorManager.Get('background'),
      child: Container(
      margin: EdgeInsets.all(18),
      child: SingleChildScrollView(child: Column(children: [...childs]),)
    ),
    );
  }
}
