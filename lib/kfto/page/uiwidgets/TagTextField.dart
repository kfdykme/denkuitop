
import 'package:denkuitop/common/ColorManager.dart';
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


  Widget _view;


  KfTodoTextField ({ onChange: Function, prefixColor: Color}) {
    if (prefixColor == null) {
      prefixColor = Color.fromARGB(255, 74, 137, 92);
    }
    tagsFieldController = KfTodoTextFieldController(onChange: onChange);
    _view = TextFieldTags(
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
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: 
                    RawKeyboardListener(
                      focusNode: fn,
                      onKey: (RawKeyEvent event) {
                        if (event.data.logicalKey.keyId == 0x100000008) {
                          tagsFieldController.tryDeleteTag();
                        }
                      },
                      child:
                    TextField(
                      controller: tec,
                      // focusNode: fn,R
                      decoration: InputDecoration(
                        isDense: true,
                        border: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color.fromARGB(204, 237, 240, 95),
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Color(0x6200EEFF),
                            width: 0.5,
                          ),
                        ),
                        // helperText: 'Enter Filter key',
                        // helperStyle: const TextStyle(
                        //   color: Color.fromARGB(255, 74, 137, 92),
                        // ),
                        hintText: tagsFieldController.hasTags ? '' : "Enter tag...",
                        errorText: error,
                        // prefixIconConstraints:
                            // BoxConstraints(maxWidth: _distanceToField * 0.74),
                        prefixIcon: tags.isNotEmpty
                            ? SingleChildScrollView(
                                controller: sc,
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                    children: tags.map((String tag) {
                                  return Container(
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(20.0),
                                      ),
                                      color: Colors.amberAccent,
                                    ),
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 5.0),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 5.0),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        InkWell(
                                          child: Text(
                                            '$tag',
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                          onTap: () {
                                            print("$tag selected");
                                          },
                                        ),
                                        const SizedBox(width: 4.0),
                                        InkWell(
                                          child: const Icon(
                                            Icons.cancel,
                                            size: 14.0,
                                            color: Color.fromARGB(
                                                255, 233, 233, 233),
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
                            : null,
                      ),
                      onChanged: onChanged,
                      onSubmitted: onSubmitted,
                    ),
                  ));});}
              );


  }

  Widget view() {
    return _view;
  }
}