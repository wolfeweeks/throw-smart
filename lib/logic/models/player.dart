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

  Player({required this.firstName, required this.lastName, required this.uid});
}
