import 'package:flutter/material.dart';
import '../../constants/colors.dart';

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
          fit: BoxFit.scaleDown,
          child: Text(
            text,
            style: TextStyle(
              fontSize: 40,
              color: groupValue == value ? Colors.black : tsYellow,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
