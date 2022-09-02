
import 'package:denkuitop/common/ColorManager.dart';
import 'package:denkuitop/common/TextK.dart';
import 'package:denkuitop/kfto/page/view/ViewBuilder.dart';
import 'package:flutter/material.dart';
import 'package:textfield_tags/textfield_tags.dart';
import 'package:rxdart/rxdart.dart';


class KfTodoTextFieldController extends TextfieldTagsController {
  
  Function onChangeCallback;

  String currentCache = "";

  // bool lastTagReadDelete = false;

  final _doublesDeleteTag = BehaviorSubject<int>();

  KfTodoTextFieldController ({ onChange: Function}) {
    onChangeCallback = onChange;

    _doublesDeleteTag.debounceTime(Duration(milliseconds: 100))
    .listen((event) {
        if (this.currentCache.trim() == "" || getTags.last.trim() == this.currentCache.trim()) {
        // remove last tags
        if (getTags.length > 0) {

          print("tryDeleteTag ${getTags} ${getTags.last}");
          onTagDelete(getTags.last);
          if (getTags.length > 0) {
            this.currentCache = getTags.last;
          }


          if (onChangeCallback != null) {
            onChangeCallback(getTags.join(","));
          }
        }
      }
    });
  }


  @override
  void onChanged(String value) {
    super.onChanged(value);
    currentCache = value;
    if (onChangeCallback != null) {
      var tags = getTags;
      tags.add(value);
      onChangeCallback(tags.join(","));
    }
  } 

  onClickDelete() {

    if (onChangeCallback != null) {
      onChangeCallback(getTags.join(","));
    }
  }

  @override
  void onSubmitted(String value) {
    // TODO: implement onSubmitted
    super.onSubmitted(value);

    if (onChangeCallback != null) {
      onChangeCallback(getTags.join(","));
    }
  }

  void tryDeleteTag () {
    _doublesDeleteTag.add(1);
  }
}

class KfTodoTextField {

  KfTodoTextFieldController tagsFieldController;

  Color textFieldColor = null;


  KfTodoTextField ({ onChange: Function, prefixColor: Color}) {
    if (prefixColor == null) {
      prefixColor = Color.fromARGB(255, 74, 137, 92);
    }
    tagsFieldController = KfTodoTextFieldController(onChange: onChange);


  }

  Widget view() {
    return TextFieldTags(
              textfieldTagsController: tagsFieldController,
              initialTags: const [
              ],
              textSeparators: const [' ', ','],
              letterCase: LetterCase.normal,
              validator: (String tag) {
                if (tag == 'php') {
                  return 'No, please just no';
                } else if (tagsFieldController.getTags.contains(tag)) {
                  return 'you already entered that';
                }
                return null;
              },
              inputfieldBuilder:
                  (context, tec, fn, error, onChanged, onSubmitted) {
                return ((context, sc, tags, onTagDelete) {
                  print("rebuild TextFieldTags");
                  return Container(
                    margin: EdgeInsets.all(ViewBuilder.size(1)),
                    // color:  ColorManager.Get("tagtextfieldlight"),
                    height: 40,
                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                    child: 
                    RawKeyboardListener(
                      focusNode: fn,
                      onKey: (RawKeyEvent event) {
                        if (event.data.logicalKey.keyId == 0x100000008) {
                          tagsFieldController.tryDeleteTag();
                        }
                      },
                      child:Row(
                        children: [Container(
                          color: ColorManager.Get("textr"),
                          margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          width: 5,
                        ),
                        Expanded(child:
                    TextField(
                      controller: tec,
                      cursorHeight: 26,
                      // focusNode: fn,R
                      style: TextStyle(color: ColorManager.Get("font")),
                      decoration: InputDecoration(
                        isDense: true,
                        hintText: tagsFieldController.hasTags ? '' : TextK.Get("Enter tag..."),
                        hintStyle: TextStyle(color: ColorManager.Get("font")),
                        enabledBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(
                            color: Color(0x00000000)
                          )
                        ),
                        
                        focusedBorder: new UnderlineInputBorder(
                          borderSide: new BorderSide(
                            color: Color(0x00000000)
                          )
                        ),
                        errorText: error,
                        // prefixIconConstraints:
                            // BoxConstraints(maxWidth: _distanceToField * 0.74),
                        prefixIcon: tags.isNotEmpty
                            ? SingleChildScrollView(
                                controller: sc,
                                
                                scrollDirection: Axis.horizontal,
                                child: Container(
                                  height: 26,
                                  padding: EdgeInsets.zero,
                                  // color: Colors.black,
                                  child: Row(
                                    
                                    children: tags.map((String tag) {
                                  return Container(
                                    color: ColorManager.Get("textr"),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0, vertical: 0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            '$tag',
                                            style: TextStyle(
                                                color: ColorManager.Get("tagtextfielddark"),
                                                ),
                                          ),
                                          onTap: () {
                                            print("$tag selected");
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: ColorManager.Get("tagtextfielddark"),
                                          ),
                                          onTap: () {
                                            onTagDelete(tag);
                                            tagsFieldController.onClickDelete();
                                          },
                                        )
                                      ],
                                    ),
                                  );
                                }).toList()),
                                )
                              )
                            : null
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ))],
                      ),
                  ));});}
              );
  }
}