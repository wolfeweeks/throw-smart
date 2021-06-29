import 'package:flutter/material.dart';
import 'package:throw_smart/constants/colors.dart';

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
      this.height = 60,
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
        // height: height,
        width: width,
        child: TextField(
          decoration: InputDecoration(
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: tsLightBlue,
                width: 2,
              ),
              gapPadding: 5,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide(
                color: tsYellow,
                width: 2,
              ),
              gapPadding: 5,
            ),
            hintText: hintText,
            fillColor: tsPaleBlue,
            focusColor: tsYellow,
            filled: true,
            hoverColor: tsYellow,
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
