import 'package:flutter/material.dart';

class TSTextField extends StatelessWidget {
  final EdgeInsetsGeometry padding;
  final double height;
  final double width;
  final String hintText;
  final TextCapitalization textCapitalization;
  final bool autocorrect;
  final void Function(String)? onChanged;
  final void Function()? onEditingComplete;
  final TextInputType? keyboardType;

  const TSTextField(
      {required this.padding,
      required this.height,
      required this.width,
      required this.hintText,
      required this.textCapitalization,
      required this.autocorrect,
      this.onChanged,
      this.onEditingComplete,
      this.keyboardType});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        height: height,
        width: width,
        child: TextField(
          decoration: InputDecoration(
            hintText: hintText,
          ),
          textCapitalization: textCapitalization,
          autocorrect: autocorrect,
          onChanged: onChanged,
          onEditingComplete: onEditingComplete,
          keyboardType: keyboardType,
        ),
      ),
    );
  }
}
