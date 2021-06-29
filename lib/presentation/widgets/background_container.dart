import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/colors.dart';
import '../../logic/general_providers.dart';

class BackgroundContainer extends ConsumerWidget {
  final Widget child;

  BackgroundContainer({required this.child});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            tsDarkBlue,
            tsLightBlue,
          ],
          center: Alignment.topLeft,
          stops: [0.5, 1],
          radius: sqrt(pow(context.read(widthProvider(context)), 2) +
                  pow(context.read(heightProvider(context)), 2)) /
              context.read(widthProvider(context)),
        ),
      ),
      child: child,
    );
  }
}
