import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../constants/enums.dart';

final dbProvider = Provider<DBRepository>((ref) => DBRepository());

class DBRepository {
  final _db = FirebaseFirestore.instance;
  final uuid = Uuid();

  //** Create */
  Future<void> createUser({
    required String uid,
    required String firstName,
    required String lastName,
    required UserType userType,
    List<PitchType>? arsenal,
    bool isJoiningTeam = false,
    bool isCreatingTeam = false,
    String? teamAccessCode,
    String? teamName,
  }) async {
    if (userType == UserType.player) {
      List<String> arsenalAsStrings = [];
      arsenal!.forEach((element) {
        arsenalAsStrings.add(element.toString());
      });

      await _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'userType': 'player',
        'arsenal': arsenalAsStrings,
      });
    }

    if (userType == UserType.coach) {
      await _db.collection('users').doc(uid).set({
        'firstName': firstName,
        'lastName': lastName,
        'userType': 'coach',
      });
      if (isCreatingTeam) {
        createTeam(teamName!, uid);
      }
    }

    if (isJoiningTeam) {
      await joinTeam(teamAccessCode!, uid, firstName, lastName, userType);
    }
  }

  void createTeam(String teamName, String ownerUID) {
    String teamID = Uuid().v1();
    _db.collection('teams').doc(ownerUID).set({
      'teamName': teamName,
      'teamID': teamID,
      'accessCode': teamID.substring(0, 8),
      'players': {},
      'otherCoaches': {},
    });
  }

  //** Read */
  DocumentReference getUserDocRef(String uid) {
    return _db.collection('users').doc(uid);
  }

  Future<bool> isValidAccessCode(String accessCode) async {
    var querySnapshot = await _db
        .collection('teams')
        .where('accessCode', isEqualTo: accessCode)
        .get();

    if (querySnapshot.size > 0) return true;

    return false;
  }

  //** Update */
  Future<void> joinTeam(String accessCode, String uid, String firstName,
      String lastName, UserType userType) async {
    var querySnapshot = await _db
        .collection('teams')
        .where('accessCode', isEqualTo: accessCode)
        .get();

    var userDocReference = getUserDocRef(uid);

    var teamDocReference = querySnapshot.docs[0].reference;
    var teamDocSnapshot = await teamDocReference.get();

    if (userType == UserType.player) {
      Map<String, dynamic> players = teamDocSnapshot['players'];
      players[uid] = firstName + ' ' + lastName;
      await teamDocReference.update({'players': players});
    }

    if (userType == UserType.coach) {
      Map<String, dynamic> otherCoaches = teamDocSnapshot['otherCoaches'];
      otherCoaches[uid] = firstName + ' ' + lastName;
      await teamDocReference.update({'otherCoaches': otherCoaches});
    }

    await userDocReference.update({'team': teamDocReference.id});
  }

  //** Delete */
  Future<void> deleteUser({
    required String uid,
    required UserType userType,
  }) async {
    await removeUserFromTeam(uid: uid, userType: userType);
    await _db.collection('users').doc(uid).delete();
  }

  Future<void> removeUserFromTeam({
    required String uid,
    required UserType userType,
  }) async {
    var userDocReference = getUserDocRef(uid);

    var userDocSnapshot = await userDocReference.get();
    Map<String, dynamic> data = userDocSnapshot.data() as Map<String, dynamic>;
    bool isOnTeam = data.containsKey('team');

    QuerySnapshot<Map<String, dynamic>> teamDocQuery;
    if (userType == UserType.coach) {
      //check if the coach is a team owner and delete the team if so
      var teamSnapshot = await _db.collection('teams').doc(uid).get();
      if (teamSnapshot.exists) {
        await teamSnapshot.reference.delete();

        //query for users who are on this team
        var usersQuery =
            await _db.collection('users').where('team', isEqualTo: uid).get();

        //delete 'team' field for each user on the team
        usersQuery.docs.forEach((user) async {
          await user.reference.update({
            'team': FieldValue.delete(),
          });
        });
        return;
      } else if (!isOnTeam) {
        return;
      }

      teamDocQuery =
          await _db.collection('teams').orderBy('otherCoaches.$uid').get();
    } else {
      if (!isOnTeam) {
        return;
      }
      teamDocQuery =
          await _db.collection('teams').orderBy('players.$uid').get();
    }

    var teamDocReference = teamDocQuery.docs[0].reference;
    var teamDocSnapshot = await teamDocReference.get();

    if (userType == UserType.coach) {
      Map<String, dynamic> otherCoaches = teamDocSnapshot['otherCoaches'];
      otherCoaches.removeWhere((key, value) => key == uid);
      await teamDocReference.update({
        'otherCoaches': otherCoaches,
      });
    } else {
      Map<String, dynamic> players = teamDocSnapshot['players'];
      players.removeWhere((key, value) => key == uid);
      await teamDocReference.update({
        'players': players,
      });
    }

    await userDocReference.update({
      'team': FieldValue.delete(),
    });
  }
}
