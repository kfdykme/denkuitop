
import 'package:flutter/material.dart';

class KeyEventTestApp extends StatelessWidget {
  String phone;

  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: RawKeyboardListener(//for physical keyboard press
              child: TextFormField(
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(labelText: "Phone"),
                validator: (val) => val.length == 0 ? 'Enter your phone' : null,
                onSaved: (val) => this.phone = val,
                onFieldSubmitted: (_) async {
                  print("asdadda"); 
                },
              ),
               focusNode: FocusNode(),
               onKey: (RawKeyEvent event) { 
                 print(event.data.logicalKey.keyId); 
               },
      )
    );
  }
}