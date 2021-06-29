import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:throw_smart/logic/general_providers.dart';
import 'package:throw_smart/presentation/widgets/hideable.dart';

class Logo extends ConsumerWidget {
  final bool showCreatedBy;

  Logo({this.showCreatedBy = false});

  Logo.withCreatedBy({this.showCreatedBy = true});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Hero(
      tag: 'logo',
      child: Material(
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 16),
            Text(
              '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w200,
              ),
            ),
            Image.asset(
              'lib/assets/images/throw_smart_logo.png',
              fit: BoxFit.contain,
              width: context.read(widthProvider(context)) * 0.9,
            ),
            SizedBox(height: 16),
            Text(
              showCreatedBy ? 'Created by Wolfe Weeks' : '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w200,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
