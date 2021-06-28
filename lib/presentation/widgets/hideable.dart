import 'package:flutter/material.dart';

class Hideable extends StatelessWidget {
  final bool shouldShowWhen;
  final Widget child;

  const Hideable({required this.shouldShowWhen, required this.child});

  @override
  Widget build(BuildContext context) {
    return shouldShowWhen ? child : SizedBox();
  }
}
