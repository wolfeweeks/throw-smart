import 'package:flutter/material.dart';

class LayoutVisualizer extends StatelessWidget {
  final Widget child;
  late final Color backgroundColor;
  late final Color borderColor;

  LayoutVisualizer({
    required this.child,
    this.backgroundColor = Colors.transparent,
    this.borderColor = Colors.red,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(
          width: 2,
          color: borderColor,
        ),
      ),
      child: child,
    );
  }
}
