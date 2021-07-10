import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:throw_smart/presentation/widgets/logo.dart';
import '../../data/db_repository.dart';
import '../widgets/background_container.dart';
import '../../data/auth_repository.dart';

class SignInScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Center(
                      child: Logo.withCreatedBy(),
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Center(
                      child: GoogleAuthButton(
                        onPressed: () async {
                          var userCredential = await context
                              .read(authProvider)
                              .signInWithGoogle();

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

                            if (!snapshot.exists) {
                              Navigator.of(context).pushReplacementNamed(
                                '/newUser',
                                arguments: userCredential.user,
                              );
                            } else {
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
                          }
                        },
                        text: 'Sign in with Google',
                        style: AuthButtonStyle(
                          padding: EdgeInsets.all(8),
                          width: MediaQuery.of(context).size.width * 2 / 3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
