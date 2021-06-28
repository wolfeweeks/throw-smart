import 'package:flutter/material.dart';

class PickMany<T> extends StatelessWidget {
  final bool? value;
  final void Function(bool?)? onChanged;
  final double width;
  final String text;

  const PickMany({
    required this.value,
    required this.onChanged,
    required this.width,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
        ),
        SizedBox(
          width: width,
          child: Center(
            child: FittedBox(
              child: Text(text),
            ),
          ),
        ),
      ],
    );
  }
}
