import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';
import '../data/db_repository.dart';

final widthProvider = Provider.family<double, BuildContext>(
    (ref, context) => MediaQuery.of(context).size.width);

final heightProvider = Provider.family<double, BuildContext>(
    (ref, context) => MediaQuery.of(context).size.height);

final currentUserProvider =
    Provider<User?>((ref) => ref.watch(authProvider).currentUser);

final userDocReferenceProvider =
    Provider.family<DocumentReference, String>((ref, uid) {
  return ref.read(dbProvider).getUserDocRef(uid);
});
