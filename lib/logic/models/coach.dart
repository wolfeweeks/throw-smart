import 'package:cloud_firestore/cloud_firestore.dart';
import 'ts_user.dart';

class Coach implements TSUser {
  @override
  late String firstName;

  @override
  late String lastName;

  @override
  late String uid;

  Coach.fromSnapshot(DocumentSnapshot coachDoc)
      : firstName = coachDoc['firstName'],
        lastName = coachDoc['lastName'],
        uid = coachDoc['playerID'];

  Coach({required this.firstName, required this.lastName, required this.uid});
}
