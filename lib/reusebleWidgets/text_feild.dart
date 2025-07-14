import 'package:flutter/material.dart';

class MyTextFeild extends StatefulWidget {
  final String lable;
  final TextEditingController controller;
  final MyTextFieldType type;

  const MyTextFeild({
    super.key,
    required this.lable,
    required this.controller,
    required this.type,
  });

  @override
  State<MyTextFeild> createState() => _FormTextFieldState();
}

class _FormTextFieldState extends State<MyTextFeild> {
  bool eyeIconVisibility = true;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: false,
      controller: widget.controller,
      keyboardType: setKeybordType(widget.type),
      obscureText:
          widget.type == MyTextFieldType.password ? eyeIconVisibility : false,
      decoration: InputDecoration(
        // ignore: unrelated_type_equality_checks
        labelText: widget.controller != "" ? widget.lable : null,
        // ignore: unrelated_type_equality_checks
        hintText: widget.controller != "" ? widget.lable : "",
        suffixIcon:
            widget.type == MyTextFieldType.password
                ? IconButton(
                  icon: Icon(
                    eyeIconVisibility ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: () {
                    setState(() {
                      eyeIconVisibility = !eyeIconVisibility;
                    });
                  },
                )
                : null,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  setKeybordType(MyTextFieldType type) {
    if (type == MyTextFieldType.text) {
      return TextInputType.text;
    } else if (type == MyTextFieldType.password) {
      return TextInputType.visiblePassword;
    }
  }
}

enum MyTextFieldType { text, password }
