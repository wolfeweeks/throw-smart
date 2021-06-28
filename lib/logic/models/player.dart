import 'package:cloud_firestore/cloud_firestore.dart';
import '../../constants/enums.dart';
import 'ts_user.dart';

class Player implements TSUser {
  @override
  late String firstName;

  @override
  late String lastName;

  @override
  late String uid;

  List<PitchType>? arsenal;

  Player.fromSnapshot(DocumentSnapshot playerDoc) {
    this.firstName = playerDoc['firstName'];
    this.lastName = playerDoc['lastName'];
    this.uid = playerDoc['id'];
  }

  Player({required this.firstName, required this.lastName, required this.uid});
}
