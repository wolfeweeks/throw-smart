import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:throw_smart/constants/colors.dart';
import 'package:throw_smart/presentation/widgets/background_container.dart';
import 'package:throw_smart/presentation/widgets/layout_visualizer.dart';
import 'package:throw_smart/presentation/widgets/logo.dart';
import '../../constants/enums.dart';
import '../../data/auth_repository.dart';
import '../../data/db_repository.dart';
import '../../logic/general_providers.dart';
import '../widgets/hideable.dart';
import '../widgets/pick_many.dart';
import '../widgets/pick_one.dart';
import '../widgets/ts_text_field.dart';

//** Providers used for this screen only *//////////////////////////////////////
final _firstNameProvider = StateProvider<String>((ref) => '');
final _lastNameProvider = StateProvider<String>((ref) => '');

final _userTypeProvider = StateProvider<UserType?>((ref) => null);

final _createOrJoinProvider = StateProvider<int?>((ref) => 0);

final _teamAccessCodeProvider = StateProvider<String>((ref) => '');
final _teamNameProvider = StateProvider<String>((ref) => '');

final _arsenalProvider = StateProvider<List<PitchType>>((ref) => []);

final _testArsenalProvider =
    StateProvider<List<bool>>((ref) => List.filled(8, false));

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

final _signUpIndexProvider = StateProvider<int>((ref) => 0);
//** Providers used for this screen only *//////////////////////////////////////

class NewUserScreen extends ConsumerWidget {
  final User user;

  NewUserScreen({required this.user});

  @override
  Widget build(BuildContext context, ScopedReader watch) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);

    bool canSubmit = watch(_userTypeProvider).state == UserType.coach
        ? watch(_coachCanSubmitProvider)
        : watch(_playerCanSubmitProvider);

    var arsenal = watch(_arsenalProvider);
    var testArsenal = watch(_testArsenalProvider);

    double width = context.read(widthProvider(context));
    double height = context.read(heightProvider(context));

    void resetFields() {
      context.read(_firstNameProvider).state = '';
      context.read(_lastNameProvider).state = '';
      context.read(_userTypeProvider).state = null;
      context.read(_createOrJoinProvider).state = 0;
      context.read(_teamAccessCodeProvider).state = '';
      context.read(_teamNameProvider).state = '';

      context.read(_testArsenalProvider).state = List.filled(8, false);

      context.read(_arsenalProvider).state = [];

      context.read(_signUpIndexProvider).state = 0;
    }

    return Scaffold(
      body: BackgroundContainer(
        child: Center(
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: SizedBox(
              height: height,
              child: Column(
                children: [
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Center(child: Logo()),
                  ),
                  Flexible(
                    fit: FlexFit.tight,
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Hideable(
                          shouldShowWhen:
                              watch(_signUpIndexProvider).state == 0,
                          child: Column(
                            children: [
                              Text(
                                'Enter your name:',
                                style: TextStyle(
                                    color: tsPaleBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              //first name text field
                              TSTextField(
                                padding: EdgeInsets.all(16),
                                width: width - 32,
                                hintText: 'First Name:',
                                textCapitalization: TextCapitalization.words,
                                autocorrect: false,
                                onChanged: (value) {
                                  context.read(_firstNameProvider).state =
                                      value;
                                },
                                onEditingComplete: () =>
                                    FocusScope.of(context).nextFocus(),
                                keyboardType: TextInputType.name,
                              ),

                              //last name text field
                              TSTextField(
                                padding: EdgeInsets.all(16),
                                width: width - 32,
                                hintText: 'Last Name:',
                                autocorrect: false,
                                textCapitalization: TextCapitalization.words,
                                onChanged: (value) {
                                  context.read(_lastNameProvider).state = value;
                                },
                              ),
                            ],
                          ),
                        ),

                        Hideable(
                          shouldShowWhen:
                              watch(_signUpIndexProvider).state == 1,
                          child: Column(
                            children: [
                              // SizedBox(height: 16),

                              //select userType
                              Text(
                                'Register as:',
                                style: TextStyle(
                                    color: tsPaleBlue,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  PickOne<UserType>(
                                    groupValue: watch(_userTypeProvider).state,
                                    value: UserType.player,
                                    onChanged: (value) {
                                      context.read(_userTypeProvider).state =
                                          value;
                                    },
                                    text: 'Player',
                                  ),
                                  SizedBox(width: 16),
                                  PickOne<UserType>(
                                    groupValue: watch(_userTypeProvider).state,
                                    value: UserType.coach,
                                    onChanged: (value) {
                                      context.read(_userTypeProvider).state =
                                          value;
                                    },
                                    text: 'Coach',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        //if coach, show join or create buttons and team name/access code
                        //text field
                        Hideable(
                          shouldShowWhen:
                              watch(_userTypeProvider).state == UserType.coach,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              PickOne<int>(
                                groupValue: watch(_createOrJoinProvider).state,
                                value: 0,
                                onChanged: (value) {
                                  context.read(_createOrJoinProvider).state =
                                      value;
                                  context.read(_teamAccessCodeProvider).state =
                                      '';
                                },
                                text: 'Create Team',
                              ),
                              SizedBox(width: 16),
                              PickOne<int>(
                                groupValue: watch(_createOrJoinProvider).state,
                                value: 1,
                                onChanged: (value) {
                                  context.read(_createOrJoinProvider).state =
                                      value;
                                  context.read(_teamNameProvider).state = '';
                                },
                                text: 'Join Team',
                              ),
                            ],
                          ),
                        ),

                        //join or create team text field
                        Hideable(
                          shouldShowWhen:
                              watch(_userTypeProvider).state == UserType.coach,
                          child: TSTextField(
                            padding: EdgeInsets.all(16),
                            width: width - 32,
                            hintText: watch(_createOrJoinProvider).state == 0
                                ? 'Team Name:'
                                : 'Team Access Code:',
                            autocorrect: false,
                            textCapitalization: TextCapitalization.words,
                            onChanged: (value) {
                              watch(_createOrJoinProvider).state == 0
                                  ? context.read(_teamNameProvider).state =
                                      value
                                  : context
                                      .read(_teamAccessCodeProvider)
                                      .state = value;
                            },
                          ),
                        ),

                        Hideable(
                          shouldShowWhen:
                              watch(_userTypeProvider).state == UserType.player,
                          child: TSTextField(
                            padding: EdgeInsets.all(16),
                            width: width - 32,
                            hintText: 'Team Access Code:',
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            onChanged: (value) {
                              context.read(_teamAccessCodeProvider).state =
                                  value;
                            },
                          ),
                        ),

                        //arsenal selector
                        Hideable(
                          shouldShowWhen:
                              watch(_userTypeProvider).state == UserType.player,
                          child: Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('Select your pitches:'),
                                Expanded(
                                  child: ListView(
                                    padding: EdgeInsets.all(0),
                                    children: [
                                      //fourseam
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[0],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[0] = value!;

                                          if (value) {
                                            arsenal.state
                                                .add(PitchType.fourSeam);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.fourSeam);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Four-Seam',
                                      ),

                                      //twoseam
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[1],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[1] = value!;

                                          if (value) {
                                            arsenal.state
                                                .add(PitchType.twoSeam);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.twoSeam);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Two-Seam',
                                      ),

                                      //cutter
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[2],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[2] = value!;

                                          if (value) {
                                            arsenal.state.add(PitchType.cutter);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.cutter);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Cutter',
                                      ),

                                      //curve
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[3],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[3] = value!;

                                          if (value) {
                                            arsenal.state.add(PitchType.curve);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.curve);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Curveball',
                                      ),

                                      //slider
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[4],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[4] = value!;

                                          if (value) {
                                            arsenal.state.add(PitchType.slider);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.slider);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Slider',
                                      ),

                                      //change
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[5],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[5] = value!;

                                          if (value) {
                                            arsenal.state
                                                .add(PitchType.changeup);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.changeup);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Changeup',
                                      ),

                                      //splitter
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[6],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[6] = value!;

                                          if (value) {
                                            arsenal.state
                                                .add(PitchType.splitter);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.splitter);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Splitter',
                                      ),

                                      //knuckle
                                      PickMany<PitchType>(
                                        value: watch(_testArsenalProvider)
                                            .state[7],
                                        onChanged: (value) {
                                          context
                                              .read(_testArsenalProvider)
                                              .state[7] = value!;

                                          if (value) {
                                            arsenal.state
                                                .add(PitchType.knuckleball);
                                          } else {
                                            arsenal.state
                                                .remove(PitchType.knuckleball);
                                          }

                                          testArsenal.state = testArsenal.state;
                                          arsenal.state = arsenal.state;
                                        },
                                        width: 150,
                                        text: 'Knuckleball',
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        //buttons
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    context.read(_signUpIndexProvider).state =
                                        context
                                                .read(_signUpIndexProvider)
                                                .state -
                                            1;
                                  },
                                  child: Text('Back'),
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.grey[700],
                                  ),
                                ),
                                SizedBox(width: 16),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read(_signUpIndexProvider).state =
                                        context
                                                .read(_signUpIndexProvider)
                                                .state +
                                            1;
                                  },
                                  child: Text('Continue'),
                                  style: ElevatedButton.styleFrom(
                                    primary: tsLightBlue,
                                  ),
                                ),
                                // ElevatedButton(
                                //   onPressed: canSubmit
                                //       ? () {
                                //           //sort arsenal by enum order
                                //           context.read(_arsenalProvider).state.sort(
                                //               (a, b) => a.index.compareTo(b.index));
                                //           context.read(dbProvider).createUser(
                                //                 uid: user.uid,
                                //                 firstName: context
                                //                     .read(_firstNameProvider)
                                //                     .state,
                                //                 lastName: context
                                //                     .read(_lastNameProvider)
                                //                     .state,
                                //                 userType: context
                                //                     .read(_userTypeProvider)
                                //                     .state!,
                                //                 arsenal: context
                                //                     .read(_arsenalProvider)
                                //                     .state,
                                //                 isCreatingTeam: context
                                //                             .read(
                                //                                 _createOrJoinProvider)
                                //                             .state ==
                                //                         0
                                //                     ? true
                                //                     : false,
                                //                 isJoiningTeam: context
                                //                         .read(
                                //                             _teamAccessCodeProvider)
                                //                         .state
                                //                         .isNotEmpty
                                //                     ? true
                                //                     : false,
                                //                 // isJoiningTeam: context
                                //                 //             .read(_createOrJoinProvider)
                                //                 //             .state ==
                                //                 //         1
                                //                 //     ? true
                                //                 //     : false,
                                //                 teamAccessCode: context
                                //                     .read(_teamAccessCodeProvider)
                                //                     .state,
                                //                 teamName: context
                                //                     .read(_teamNameProvider)
                                //                     .state,
                                //               );
                                //           var tempUserType =
                                //               context.read(_userTypeProvider).state;

                                //           resetFields();

                                //           tempUserType == UserType.coach
                                //               ? Navigator.of(context)
                                //                   .pushReplacementNamed(
                                //                       '/coachHome',
                                //                       arguments: user.uid)
                                //               : Navigator.of(context)
                                //                   .pushReplacementNamed(
                                //                       '/playerHome',
                                //                       arguments: user.uid);
                                //         }
                                //       : null,
                                //   child: Text('Submit'),
                                //   style: ElevatedButton.styleFrom(
                                //     primary: canSubmit ? tsLightBlue : Colors.grey,
                                //   ),
                                // ),
                              ],
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: tsRed,
                              ),
                              onPressed: () async {
                                try {
                                  await context
                                      .read(authProvider)
                                      .deleteAccount();
                                } on FirebaseAuthException catch (e) {
                                  print(e.toString());
                                }
                                await context.read(authProvider).signOut();
                                resetFields();
                                Navigator.of(context)
                                    .pushReplacementNamed('/signIn');
                              },
                              child: Text('Cancel'),
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
    );
  }
}
