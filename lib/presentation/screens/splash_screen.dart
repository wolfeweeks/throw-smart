import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
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
      backgroundColor: Colors.greenAccent,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('ThrowSmart'),
          ],
        ),
      ),
    );
  }
}
