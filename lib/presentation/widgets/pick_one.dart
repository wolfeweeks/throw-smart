import 'package:flutter/material.dart';

class PickOne<T> extends StatelessWidget {
  final T? groupValue;
  final T value;
  final void Function(T?)? onChanged;
  final String text;

  PickOne({
    required this.groupValue,
    required this.value,
    required this.onChanged,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Radio<T>(
          groupValue: groupValue,
          value: value,
          onChanged: onChanged,
        ),
        Text(text),
      ],
    );
    //TODO make custom pickone
    // return Container(

    //   child: Text(text),
    // );
  }
}
