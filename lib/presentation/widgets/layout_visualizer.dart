import 'package:flutter/material.dart';

class LayoutVisualizer extends StatelessWidget {
  final Widget child;
  late final Color backgroundColor;
  late final Color borderColor;

  LayoutVisualizer({
    required this.child,
    this.backgroundColor = Colors.red,
    this.borderColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}
