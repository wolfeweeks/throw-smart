import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:throw_smart/constants/colors.dart';
import 'package:throw_smart/data/db_repository.dart';
import '../../logic/general_providers.dart';

class SplashScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    var user = watch(currentUserProvider);

    //wait 3 seconds
    Future.delayed(Duration(seconds: 3), () async {
      if (user != null) {
        var snapshot =
            await context.read(dbProvider).getUserDocRef(user.uid).get();

        if (snapshot['userType'] == 'coach') {
          Navigator.of(context).pushReplacementNamed(
            '/coachHome',
            arguments: user.uid,
          );
        } else {
          Navigator.of(context).pushReplacementNamed(
            '/playerHome',
            arguments: user.uid,
          );
        }
      } else {
        Navigator.of(context).pushReplacementNamed('/signIn');
      }
    });

    return Scaffold(
      // backgroundColor: Colors.greenAccent,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              tsDarkBlue,
              tsLightBlue,
            ],
            center: Alignment.topLeft,
            stops: [0.5, 1],
            // radius: 2,
            radius: sqrt(pow(context.read(widthProvider(context)), 2) +
                    pow(context.read(heightProvider(context)), 2)) /
                context.read(widthProvider(context)),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: Material(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      Image.asset(
                        'lib/assets/images/throw_smart_logo.png',
                        fit: BoxFit.contain,
                        width: context.read(widthProvider(context)) * 0.9,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Created by Wolfe Weeks',
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
