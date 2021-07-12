import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/colors.dart';
import 'hideable.dart';

class PickMany<T> extends StatelessWidget {
  final bool isSelected;
  final ValueSetter<bool?> onChanged;
  final double? width;
  final double height;
  final String text;
  final Color color;
  final Color textColor;

  const PickMany({
    required this.isSelected,
    required this.onChanged,
    required this.width,
    this.height = 60,
    required this.text,
    this.color = Colors.transparent,
    this.textColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          onChanged(this.isSelected);
        },
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? tsYellow : Colors.black.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: EdgeInsets.all(8),
            width: width ?? null,
            height: height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  child: Text(
                    text,
                    style: TextStyle(
                      color: isSelected ? tsDarkBlue : textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                Hideable(
                  shouldShowWhen: isSelected,
                  child: FittedBox(
                    child: Icon(
                      FontAwesomeIcons.check,
                      color: isSelected ? tsDarkBlue : textColor,
                    ),
                  ),
                ),
                // Container(
                //   width: height,
                //   height: height,
                //   decoration: BoxDecoration(
                //     shape: BoxShape.circle,
                //     gradient: LinearGradient(
                //       colors: [
                //         value
                //             ? Color.lerp(color, Colors.black, 0.25)!
                //             : Color.lerp(tsPaleBlue, Colors.white, 0.25)!,
                //         value
                //             ? Color.lerp(color, Colors.white, 0.25)!
                //             : Color.lerp(tsPaleBlue, Colors.black, 0.25)!,
                //         // Colors.black.withOpacity(0.25),
                //         // Colors.white.withOpacity(0.5),
                //       ],
                //       begin: Alignment(0, -1),
                //       end: Alignment(0, 1),
                //       // center: Alignment(0, -0.5),
                //       // stops: [0, 0.5],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
    // return Row(
    //   mainAxisAlignment: MainAxisAlignment.center,
    //   mainAxisSize: MainAxisSize.min,
    //   children: [
    //     Checkbox(
    //       value: value,
    //       onChanged: onChanged,
    //     ),
    //     SizedBox(
    //       width: width,
    //       child: Center(
    //         child: FittedBox(
    //           child: Text(text),
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }
}
