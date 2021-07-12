import 'package:flutter/material.dart';

class TSButton extends StatelessWidget {
  final void Function()? onPressed;
  final String text;
  final double width;
  final double height;
  final Color color;
  final Color textColor;
  final bool isSunken;

  TSButton({
    required this.onPressed,
    required this.text,
    required this.color,
    required this.textColor,
    this.width = 125,
    this.height = 50,
    this.isSunken = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        // padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color:
              onPressed == null ? Colors.grey[700]!.withOpacity(0.25) : color,
          border: Border.all(
            color: onPressed == null ? Colors.grey[900]! : color,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: onPressed == null
                ? null
                : LinearGradient(
                    colors: [
                      isSunken
                          ? Colors.black.withOpacity(0.25)
                          : Colors.white.withOpacity(0.25),
                      isSunken
                          ? Colors.white.withOpacity(0.25)
                          : Colors.black.withOpacity(0.25),
                    ],
                    begin: Alignment(0, -1),
                    end: Alignment(0, 1),
                  ),
            borderRadius: BorderRadius.circular(999),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                fontSize: 40,
                color: onPressed == null
                    ? Colors.grey[900]!.withOpacity(0.75)
                    : textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
