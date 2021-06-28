import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'presentation/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(ProviderScope(child: ThrowSmart()));
}

final appRouterProvider = Provider<AppRouter>((ref) => AppRouter());

class ThrowSmart extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          print(snapshot.error.toString());
          return CircularProgressIndicator();
        }

        if (snapshot.connectionState == ConnectionState.done) {
          return MaterialApp(
            title: 'ThrowSmart',
            debugShowCheckedModeBanner: false,
            onGenerateRoute: context
                .read(
                  appRouterProvider,
                )
                .onGenerateRoute,
          );
        }
        return CircularProgressIndicator();
      },
    );
  }
}
