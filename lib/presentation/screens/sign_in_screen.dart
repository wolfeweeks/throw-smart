import 'dart:math';

import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:throw_smart/constants/colors.dart';
import 'package:throw_smart/data/db_repository.dart';
import 'package:throw_smart/logic/general_providers.dart';
import '../../data/auth_repository.dart';

class SignInScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      // backgroundColor: Colors.blueAccent,
      body: Container(
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
              SizedBox(
                height: 100,
              ),
              GoogleAuthButton(
                onPressed: () async {
                  var userCredential =
                      await context.read(authProvider).signInWithGoogle();

                  if (userCredential!.additionalUserInfo!.isNewUser) {
                    Navigator.of(context).pushReplacementNamed(
                      '/newUser',
                      arguments: userCredential.user,
                    );
                  } else {
                    var snapshot = await context
                        .read(dbProvider)
                        .getUserDocRef(userCredential.user!.uid)
                        .get();

                    if (snapshot['userType'] == 'coach') {
                      Navigator.of(context).pushReplacementNamed(
                        '/coachHome',
                        arguments: userCredential.user!.uid,
                      );
                    } else {
                      Navigator.of(context).pushReplacementNamed(
                        '/playerHome',
                        arguments: userCredential.user!.uid,
                      );
                    }
                  }
                },
                text: 'Sign in with Google',
                style: AuthButtonStyle(
                  padding: EdgeInsets.all(8),
                  width: MediaQuery.of(context).size.width * 2 / 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
