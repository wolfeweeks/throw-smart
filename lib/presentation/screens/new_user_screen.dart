import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../constants/colors.dart';
import '../../data/db_repository.dart';
import '../widgets/background_container.dart';
import '../widgets/button.dart';
import '../widgets/logo.dart';
import '../../constants/enums.dart';
import '../../data/auth_repository.dart';
import '../../logic/general_providers.dart';
import '../widgets/hideable.dart';
import '../widgets/pick_many.dart';
import '../widgets/pick_one.dart';
import '../widgets/ts_text_field.dart';

//** Providers used for this screen only *//////////////////////////////////////
final _signUpIndexProvider = StateProvider<int>((ref) => 0);

final _firstNameProvider = StateProvider<String>((ref) => '');
final _firstNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());
final _lastNameProvider = StateProvider<String>((ref) => '');
final _lastNameControllerProvider =
    Provider<TextEditingController>((ref) => TextEditingController());

final _userTypeProvider = StateProvider<UserType?>((ref) => null);

final _createOrJoinProvider = StateProvider<int?>((ref) => 0);

final _teamAccessCodeProvider = StateProvider<String>((ref) => '');
final _teamNameProvider = StateProvider<String>((ref) => '');

final _arsenalProvider = StateProvider<List<PitchType>>((ref) => []);
final _arsenalListScrollControllerProvider =
    Provider<ScrollController>((ref) => ScrollController());

final _coachCanSubmitProvider = Provider<bool>((ref) {
  return ref.watch(_firstNameProvider).state.isNotEmpty &&
      ref.watch(_lastNameProvider).state.isNotEmpty &&
      (ref.watch(_teamAccessCodeProvider).state.isNotEmpty ||
          ref.watch(_teamNameProvider).state.isNotEmpty);
});
final _playerCanSubmitProvider = Provider<bool>((ref) {
  var arsenal = ref.watch(_arsenalProvider);

  return ref.watch(_userTypeProvider).state != null &&
      ref.watch(_firstNameProvider).state.isNotEmpty &&
      ref.watch(_lastNameProvider).state.isNotEmpty &&
      arsenal.state.isNotEmpty;
});
//** Providers used for this screen only *//////////////////////////////////////

//** User State Notifier Provider*/
// final _tsUserStateNotifierProvider =
//     StateNotifierProvider<TSUserStateNotifier, TSUser?>(
//         (ref) => TSUserStateNotifier());
//** User State Notifier Provider*/

class NewUserScreen extends ConsumerWidget {
  final User user;

  NewUserScreen({required this.user});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    // var tsUser = watch(_tsUserStateNotifierProvider);

    bool canSubmit = watch(_userTypeProvider).state == UserType.coach
        ? watch(_coachCanSubmitProvider)
        : watch(_playerCanSubmitProvider);

    var arsenal = watch(_arsenalProvider);

    double width = watch(widthProvider(context));
    double height = watch(heightProvider(context));

    String getTopText() {
      switch (watch(_signUpIndexProvider).state) {
        case 0:
          return 'Enter your name:';
        case 1:
          return 'Register as a:';
        case 2:
          if (context.read(_userTypeProvider).state == UserType.coach) {
            return 'Join or create a team:';
          } else {
            return 'Select your arsenal:';
          }
        case 3:
          return 'Join a team (Optional):';
        default:
          return '';
      }
    }

    void resetFields() {
      context.read(_firstNameProvider).state = '';
      context.read(_firstNameControllerProvider).clear();
      context.read(_lastNameProvider).state = '';
      context.read(_lastNameControllerProvider).clear();

      context.read(_userTypeProvider).state = null;

      context.read(_createOrJoinProvider).state = 0;
      context.read(_teamAccessCodeProvider).state = '';
      context.read(_teamNameProvider).state = '';

      context.read(_arsenalProvider).state = [];

      context.read(_signUpIndexProvider).state = 0;
    }

    Future<void> showBadAccessCodeAlert() async {
      showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: Row(
                children: [
                  Icon(
                    FontAwesomeIcons.exclamationTriangle,
                    color: tsRed,
                  ),
                  SizedBox(width: 16),
                  Text('Not a valid access code!'),
                ],
              ),
              actions: [
                MaterialButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'CLOSE',
                        style: TextStyle(
                          color: tsRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            );
          });
    }

    void submit() async {
      if (context.read(_teamAccessCodeProvider).state.isNotEmpty) {
        if (!(await context
            .read(dbProvider)
            .isValidAccessCode(context.read(_teamAccessCodeProvider).state))) {
          await showBadAccessCodeAlert();
          return;
        }
      }

      //sort arsenal by enum order
      context
          .read(_arsenalProvider)
          .state
          .sort((a, b) => a.index.compareTo(b.index));

      context.read(dbProvider).createUser(
            uid: user.uid,
            firstName: context.read(_firstNameProvider).state,
            lastName: context.read(_lastNameProvider).state,
            userType: context.read(_userTypeProvider).state!,
            arsenal: context.read(_arsenalProvider).state,
            isCreatingTeam:
                context.read(_createOrJoinProvider).state == 0 ? true : false,
            isJoiningTeam:
                context.read(_teamAccessCodeProvider).state.isNotEmpty
                    ? true
                    : false,
            teamAccessCode: context.read(_teamAccessCodeProvider).state,
            teamName: context.read(_teamNameProvider).state,
          );

      if (context.read(_teamAccessCodeProvider).state.isNotEmpty) {
        context.read(dbProvider).joinTeam(
              context.read(_teamAccessCodeProvider).state,
              user.uid,
              context.read(_firstNameProvider).state,
              context.read(_lastNameProvider).state,
              context.read(_userTypeProvider).state!,
            );
      }

      var tempUserType = context.read(_userTypeProvider).state;

      resetFields();

      tempUserType == UserType.coach
          ? Navigator.of(context)
              .pushReplacementNamed('/coachHome', arguments: user.uid)
          : Navigator.of(context)
              .pushReplacementNamed('/playerHome', arguments: user.uid);
    }

    bool lastPage = (watch(_userTypeProvider).state == UserType.coach &&
            watch(_signUpIndexProvider).state == 2) ||
        (watch(_signUpIndexProvider).state == 3);

    bool canContinue() {
      switch (watch(_signUpIndexProvider).state) {
        case 0:
          return watch(_firstNameProvider).state.isNotEmpty &&
              watch(_lastNameProvider).state.isNotEmpty;
        case 1:
          return watch(_userTypeProvider).state != null;
        case 2:
          if (context.read(_userTypeProvider).state == UserType.coach) {
            return watch(_teamAccessCodeProvider).state.isNotEmpty ||
                watch(_teamNameProvider).state.isNotEmpty;
          } else {
            return watch(_arsenalProvider).state.isNotEmpty;
          }
        default:
          return false;
      }
    }

    return Scaffold(
      body: BackgroundContainer(
        child: SafeArea(
          child: Center(
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return false;
              },
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(),
                child: SizedBox(
                  height: height - MediaQuery.of(context).padding.top,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        //* top section
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 1,
                          child: Center(child: Logo.withCreatedBy()),
                        ),

                        //* bottom section
                        Flexible(
                          fit: FlexFit.tight,
                          flex: 2,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    //top text
                                    Text(
                                      getTopText(),
                                      style: TextStyle(
                                        color: tsPaleBlue,
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),

                                    SizedBox(height: 16),

                                    //name fields
                                    Hideable(
                                      shouldShowWhen:
                                          watch(_signUpIndexProvider).state ==
                                              0,
                                      child: NameFields(width: width),
                                    ),

                                    //user type pick ones
                                    Hideable(
                                      shouldShowWhen:
                                          watch(_signUpIndexProvider).state ==
                                              1,
                                      child: UserTypePickOnes(width: width),
                                    ),

                                    //join or create team pick ones and field
                                    Hideable(
                                      shouldShowWhen:
                                          watch(_signUpIndexProvider).state ==
                                                  2 &&
                                              watch(_userTypeProvider).state ==
                                                  UserType.coach,
                                      child: JoinOrCreate(width: width),
                                    ),

                                    //arsenal selector
                                    Hideable(
                                      shouldShowWhen:
                                          watch(_signUpIndexProvider).state ==
                                                  2 &&
                                              watch(_userTypeProvider).state ==
                                                  UserType.player,
                                      child: ArsenalList(
                                        arsenal: arsenal,
                                      ),
                                    ),

                                    //join team (for players)
                                    Hideable(
                                      shouldShowWhen:
                                          watch(_signUpIndexProvider).state ==
                                                  3 &&
                                              watch(_userTypeProvider).state ==
                                                  UserType.player,
                                      child: TSTextField(
                                        padding: EdgeInsets.only(top: 16),
                                        width: width,
                                        hintText: 'Team Access Code:',
                                        autocorrect: false,
                                        textCapitalization:
                                            TextCapitalization.none,
                                        onChanged: (value) {
                                          context
                                              .read(_teamAccessCodeProvider)
                                              .state = value;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              //buttons
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TSButton(
                                        onPressed: context
                                                    .read(_signUpIndexProvider)
                                                    .state !=
                                                0
                                            ? () {
                                                context
                                                    .read(_signUpIndexProvider)
                                                    .state = context
                                                        .read(
                                                            _signUpIndexProvider)
                                                        .state -
                                                    1;
                                              }
                                            : null,
                                        text: 'Back',
                                        isSunken: true,
                                        color: Colors.grey[700]!,
                                        textColor: Colors.white,
                                      ),
                                      SizedBox(width: 16),
                                      lastPage
                                          ? TSButton(
                                              onPressed: canSubmit
                                                  ? () {
                                                      submit();
                                                    }
                                                  : null,
                                              text: 'Submit',
                                              isSunken: false,
                                              color: tsLightBlue,
                                              textColor: Colors.white,
                                            )
                                          : TSButton(
                                              onPressed: canContinue()
                                                  ? () {
                                                      context
                                                          .read(
                                                              _signUpIndexProvider)
                                                          .state = context
                                                              .read(
                                                                  _signUpIndexProvider)
                                                              .state +
                                                          1;
                                                    }
                                                  : null,
                                              text: 'Continue',
                                              isSunken: false,
                                              color: tsDarkBlue,
                                              textColor: Colors.white,
                                            ),
                                    ],
                                  ),
                                  SizedBox(height: 16),
                                  TSButton(
                                    onPressed: () async {
                                      try {
                                        await context
                                            .read(authProvider)
                                            .deleteAccount();
                                      } on FirebaseAuthException catch (e) {
                                        print(e.toString());
                                      }
                                      await context
                                          .read(authProvider)
                                          .signOut();
                                      resetFields();
                                      Navigator.of(context)
                                          .pushReplacementNamed('/signIn');
                                    },
                                    text: 'Cancel',
                                    isSunken: true,
                                    color: tsRed,
                                    textColor: Colors.white,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ArsenalList extends ConsumerWidget {
  const ArsenalList({
    Key? key,
    required this.arsenal,
  }) : super(key: key);

  final StateController<List<PitchType>> arsenal;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: tsPaleBlue,
          border: Border.all(
            color: tsYellow,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Scrollbar(
                isAlwaysShown: true,
                interactive: true,
                radius: Radius.circular(999),
                controller: watch(_arsenalListScrollControllerProvider),
                thickness: 10,
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowGlow();
                    return false;
                  },
                  child: ListView(
                    controller: watch(_arsenalListScrollControllerProvider),
                    padding: EdgeInsets.only(right: 21),
                    children: [
                      //fourseam
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.fourSeam),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.fourSeam);
                          } else {
                            arsenal.state.remove(PitchType.fourSeam);
                          }
                          arsenal.state = arsenal.state;
                          print(arsenal.state);
                        },
                        width: 150,
                        text: 'Four-Seam',
                      ),

                      //twoseam
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.twoSeam),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.twoSeam);
                          } else {
                            arsenal.state.remove(PitchType.twoSeam);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Two-Seam',
                      ),

                      //cutter
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.cutter),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.cutter);
                          } else {
                            arsenal.state.remove(PitchType.cutter);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Cutter',
                      ),

                      //curve
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.curve),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.curve);
                          } else {
                            arsenal.state.remove(PitchType.curve);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Curveball',
                      ),

                      //slider
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.slider),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.slider);
                          } else {
                            arsenal.state.remove(PitchType.slider);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Slider',
                      ),

                      //change
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.changeup),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.changeup);
                          } else {
                            arsenal.state.remove(PitchType.changeup);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Changeup',
                      ),

                      //splitter
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.splitter),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.splitter);
                          } else {
                            arsenal.state.remove(PitchType.splitter);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Splitter',
                      ),

                      //knuckle
                      PickMany<PitchType>(
                        isSelected: watch(_arsenalProvider)
                            .state
                            .contains(PitchType.knuckleball),
                        onChanged: (value) {
                          if (!value!) {
                            arsenal.state.add(PitchType.knuckleball);
                          } else {
                            arsenal.state.remove(PitchType.knuckleball);
                          }
                          arsenal.state = arsenal.state;
                        },
                        width: 150,
                        text: 'Knuckleball',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JoinOrCreate extends ConsumerWidget {
  const JoinOrCreate({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Column(
      children: [
        //if coach, show join or create buttons and team name/access code
        //text field
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            PickOne<int>(
              groupValue: watch(_createOrJoinProvider).state,
              value: 0,
              onChanged: (value) {
                context.read(_createOrJoinProvider).state = value;
                context.read(_teamAccessCodeProvider).state = '';
              },
              text: 'Create Team',
            ),
            SizedBox(width: 16),
            PickOne<int>(
              groupValue: watch(_createOrJoinProvider).state,
              value: 1,
              onChanged: (value) {
                context.read(_createOrJoinProvider).state = value;
                context.read(_teamNameProvider).state = '';
              },
              text: 'Join Team',
            ),
          ],
        ),

        //join or create team text field
        TSTextField(
          padding: EdgeInsets.only(top: 16),
          width: width,
          hintText: watch(_createOrJoinProvider).state == 0
              ? 'Team Name:'
              : 'Team Access Code:',
          autocorrect: false,
          textCapitalization: watch(_createOrJoinProvider).state == 0
              ? TextCapitalization.words
              : TextCapitalization.none,
          onChanged: (value) {
            watch(_createOrJoinProvider).state == 0
                ? context.read(_teamNameProvider).state = value
                : context.read(_teamAccessCodeProvider).state = value;
          },
        ),
      ],
    );
  }
}

class UserTypePickOnes extends ConsumerWidget {
  const UserTypePickOnes({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PickOne<UserType>(
          groupValue: watch(_userTypeProvider).state,
          value: UserType.player,
          onChanged: (value) {
            context.read(_userTypeProvider).state = value;
          },
          text: 'Player',
        ),
        SizedBox(height: 16),
        PickOne<UserType>(
          groupValue: watch(_userTypeProvider).state,
          value: UserType.coach,
          onChanged: (value) {
            context.read(_userTypeProvider).state = value;
          },
          text: 'Coach',
        ),
      ],
    );
  }
}

class NameFields extends ConsumerWidget {
  const NameFields({
    Key? key,
    required this.width,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    return Column(
      children: [
        //first name text field
        TSTextField(
          controller: watch(_firstNameControllerProvider),
          padding: EdgeInsets.symmetric(vertical: 16),
          width: width,
          hintText: 'First Name:',
          textCapitalization: TextCapitalization.words,
          autocorrect: false,
          onChanged: (value) {
            context.read(_firstNameProvider).state = value;
          },
          onEditingComplete: () => FocusScope.of(context).nextFocus(),
          keyboardType: TextInputType.name,
        ),

        //last name text field
        TSTextField(
          controller: watch(_lastNameControllerProvider),
          padding: EdgeInsets.symmetric(vertical: 16),
          width: width,
          hintText: 'Last Name:',
          autocorrect: false,
          textCapitalization: TextCapitalization.words,
          onChanged: (value) {
            context.read(_lastNameProvider).state = value;
          },
        ),
      ],
    );
  }
}
