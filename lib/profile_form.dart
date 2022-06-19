import 'package:calorie_budget/mixins/snack_bar.dart';
import 'package:calorie_budget/models/profile.dart';
import 'package:calorie_budget/models/profile_delta.dart';
import 'package:flutter/material.dart';

class ProfileForm extends StatefulWidget {
  final String uid;
  final Profile profile;
  final GlobalKey<FormState>? formKey;

  const ProfileForm({
    Key? key,
    required this.uid,
    required this.profile,
    this.formKey,
  }) : super(key: key);

  @override
  ProfileFormState createState() => ProfileFormState();
}

class ProfileFormState extends State<ProfileForm> with SnackBarMixin {
  late final GlobalKey<FormState> _formKey;
  late Profile profile;
  late ProfileDelta delta;

  @override
  void initState() {
    super.initState();
    _formKey =
        widget.formKey == null ? GlobalKey<FormState>() : widget.formKey!;
    profile = widget.profile;
    delta = ProfileDelta();
  }

  Future<void> saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      ThemeData themeData = Theme.of(context);
      bool? successful = await Profile.save(widget.uid, delta);
      if (successful == null) {
        showSnackBarMessage(
          'No change was made to your profile.',
          backgroundColor: themeData.colorScheme.secondary,
        );
      } else if (successful) {
        showSnackBarMessage(
          'Profile successfully saved.',
          backgroundColor: themeData.colorScheme.secondary,
        );
      } else {
        showSnackBarMessage(
          'Failed to save Profile.',
          backgroundColor: themeData.colorScheme.error,
        );
      }
    }
  }

  Widget buildNumberField(
    String label,
    double? initialValue,
    void Function(String)? onChanged,
    void Function(String?)? onSaved,
  ) =>
      TextFormField(
        initialValue: initialValue?.toString(),
        decoration: InputDecoration(
          labelText: label,
        ),
        onChanged: onChanged,
        onSaved: onSaved,
        keyboardType: TextInputType.number,
        validator: (value) => double.tryParse(value ?? 'empty') == null
            ? 'Please enter a valid number.'
            : null,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            DropdownButtonFormField<String>(
              value: profile.gender,
              decoration: const InputDecoration(
                labelText: 'Gender',
              ),
              validator: (dynamic value) {
                return value == 'Male' || value == 'Female'
                    ? null
                    : 'Please select "Male" or "Female".';
              },
              onChanged: (String? value) {
                if (value != null) delta.gender = value;
              },
              onSaved: (String? value) {
                if (value != null) profile.gender = value;
              },
              items: const [
                DropdownMenuItem(value: 'Male', child: Text('Male')),
                DropdownMenuItem(
                  value: 'Female',
                  child: Text('Female'),
                ),
              ],
            ),
            buildNumberField(
              'Age (years)',
              profile.age,
              (value) {
                if (double.tryParse(value) != null) {
                  delta.age = double.parse(value);
                }
              },
              (value) {
                if (double.tryParse(value ?? 'empty') != null) {
                  profile.age = double.parse(value!);
                }
              },
            ),
            buildNumberField(
              'Height (inches)',
              profile.height,
              (value) {
                if (double.tryParse(value) != null) {
                  delta.height = double.parse(value);
                }
              },
              (value) {
                if (double.tryParse(value ?? 'empty') != null) {
                  profile.height = double.parse(value!);
                }
              },
            ),
            buildNumberField(
              'Weight (lbs)',
              profile.weight,
              (value) {
                if (double.tryParse(value) != null) {
                  delta.weight = double.parse(value);
                }
              },
              (value) {
                if (double.tryParse(value ?? 'empty') != null) {
                  profile.weight = double.parse(value!);
                }
              },
            ),
            buildNumberField(
              'Calorie Deficit Goal',
              profile.deficitGoal,
              (value) {
                if (double.tryParse(value) != null) {
                  delta.deficitGoal = double.parse(value);
                }
              },
              (value) {
                if (double.tryParse(value ?? 'empty') != null) {
                  profile.deficitGoal = double.parse(value!);
                }
              },
            ),
            Wrap(
              children: [
                const Padding(
                  padding: EdgeInsets.only(
                    top: 16.0,
                    right: 16.0,
                  ),
                  child: Text(
                    'Calorie Reset Time',
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 70.0,
                        child: TextFormField(
                          textAlign: TextAlign.end,
                          decoration:
                              const InputDecoration(label: Text('Hour (0-23)')),
                          initialValue: profile.resetHour.toString(),
                          onChanged: (value) {
                            if (int.tryParse(value) != null) {
                              int numValue = int.parse(value);
                              if (numValue < 24 && numValue >= 0) {
                                delta.resetHour = numValue;
                              }
                            }
                          },
                          onSaved: (value) {
                            if (int.tryParse(value ?? 'invalid') != null) {
                              int numValue = int.parse(value!);
                              if (numValue < 24 && numValue >= 0) {
                                profile.resetHour = numValue;
                              }
                            }
                          },
                          validator: (value) {
                            if (int.tryParse(value ?? 'invalid') != null) {
                              int numValue = int.parse(value!);
                              if (numValue < 24 && numValue >= 0) return null;
                            }
                            return 'Please enter a number between 0 and 23.';
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 0.0),
                        child: Text(':', style: TextStyle(fontSize: 16.0)),
                      ),
                      SizedBox(
                        width: 70.0,
                        child: TextFormField(
                          decoration:
                              const InputDecoration(label: Text('Minute')),
                          initialValue: profile.resetMinute < 10
                              ? '0${profile.resetMinute}'
                              : profile.resetMinute.toString(),
                          onChanged: (value) {
                            if (int.tryParse(value) != null) {
                              int numValue = int.parse(value);
                              if (numValue < 60 && numValue >= 0) {
                                delta.resetMinute = numValue;
                              }
                            }
                          },
                          onSaved: (value) {
                            if (int.tryParse(value ?? 'invalid') != null) {
                              int numValue = int.parse(value!);
                              if (numValue < 60 && numValue >= 0) {
                                profile.resetMinute = numValue;
                              }
                            }
                          },
                          validator: (value) {
                            if (int.tryParse(value ?? 'invalid') != null) {
                              int numValue = int.parse(value!);
                              if (numValue < 60 && numValue >= 0) return null;
                            }
                            return 'Please enter a number between 00 and 59.';
                          },
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (widget.key == null)
              ElevatedButton(
                onPressed: () async => saveForm(),
                child: const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }
}
