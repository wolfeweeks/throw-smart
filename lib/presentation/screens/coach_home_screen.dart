import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:throw_smart/constants/enums.dart';
import '../../data/auth_repository.dart';
import '../../data/db_repository.dart';
import '../../logic/general_providers.dart';
import '../widgets/loading_data.dart';

class CoachHomeScreen extends HookWidget {
  final String uid;

  CoachHomeScreen(this.uid);

  @override
  Widget build(BuildContext context) {
    //update the last time a user logged in
    Future.delayed(Duration(seconds: 3), () {
      context
          .read(dbProvider)
          .getUserDocRef(uid)
          .update({'lastLogin': DateTime.now().toString()});
    });

    return FutureBuilder<DocumentSnapshot>(
        future: useProvider(userDocReferenceProvider(uid)).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Home Screen'),
                    SizedBox(height: 8),
                    Text(snapshot.data!['firstName'] +
                        ' ' +
                        snapshot.data!['lastName']),
                    Text(snapshot.data!['userType']),
                    SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read(authProvider).signOut();
                        Navigator.of(context).pushReplacementNamed('/signIn');
                      },
                      child: Text('Sign Out'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await context.read(authProvider).deleteAccount();
                        await context.read(authProvider).signOut();
                        await context
                            .read(dbProvider)
                            .deleteUser(uid: uid, userType: UserType.coach);
                        Navigator.of(context).pushReplacementNamed('/signIn');
                      },
                      child: Text('Delete Account'),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return LoadingData();
          }
        });
  }
}
