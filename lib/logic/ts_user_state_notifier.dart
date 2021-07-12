import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/enums.dart';
import 'models/player.dart';
import 'models/ts_user.dart';

import 'models/coach.dart';

class TSUserStateNotifier extends StateNotifier<TSUser?> {
  TSUserStateNotifier() : super(null);

  void update() => state = state;

  void reset() => state = null;

  void setAsCoach({
    required String uid,
    required String firstName,
    required String lastName,
  }) {
    state = Coach(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
    );
  }

  void setAsPlayer({
    required String uid,
    required String firstName,
    required String lastName,
  }) {
    state = Player(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
    );
  }

  void setFirstName(String firstName) {
    state?.firstName = firstName;
    update();
  }

  void setLastName(String lastName) {
    state?.lastName = lastName;
    update();
  }

  void setArsenal(List<PitchType> arsenal) {
    (state as Player).arsenal = arsenal;
    update();
  }
}
