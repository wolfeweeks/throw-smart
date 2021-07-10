import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'screens/coach_home_screen.dart';
import 'screens/player_home_screen.dart';
import 'screens/new_user_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/splash_screen.dart';

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => SplashScreen(),
        );
      case '/signIn':
        return PageRouteBuilder(
          transitionDuration: Duration(seconds: 1, milliseconds: 500),
          pageBuilder: (_, __, ___) {
            return SignInScreen();
          },
        );
      case '/newUser':
        return PageRouteBuilder(
          transitionDuration: Duration(seconds: 1, milliseconds: 500),
          pageBuilder: (_, __, ___) =>
              NewUserScreen(user: settings.arguments as User),
        );
      case '/coachHome':
        return MaterialPageRoute(builder: (context) {
          String uid = settings.arguments as String;
          return CoachHomeScreen(uid);
        });
      case '/playerHome':
        return MaterialPageRoute(builder: (context) {
          String uid = settings.arguments as String;
          return PlayerHomeScreen(uid);
        });
    }
  }
}
