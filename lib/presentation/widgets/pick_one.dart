import 'package:flutter/material.dart';
import 'package:throw_smart/constants/colors.dart';

class PickOne<T> extends StatelessWidget {
  final T? groupValue;
  final T value;
  final ValueSetter<T?> onChanged;
  final String text;
  final double width;
  final double height;

  PickOne({
    required this.groupValue,
    required this.value,
    required this.onChanged,
    required this.text,
    this.width = 125,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     Radio<T>(
    //       groupValue: groupValue,
    //       value: value,
    //       onChanged: onChanged,
    //     ),
    //     Text(text),
    //   ],
    // );
    //TODO make custom pickone

    return GestureDetector(
      onTap: () {
        onChanged(this.value);
      },
      child: Container(
        width: width,
        height: height,
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: groupValue == value ? tsYellow : tsYellow.withOpacity(0.25),
          border: Border.all(
            color: tsYellow,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: FittedBox(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 20,
              color: groupValue == value ? Colors.black : tsYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
