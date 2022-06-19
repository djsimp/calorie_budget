import 'dart:async';
import 'package:calorie_budget/buttons/sign_out.dart';
import 'package:calorie_budget/loading.dart';
import 'package:calorie_budget/models/food_entry.dart';
import 'package:calorie_budget/models/food_log.dart';
import 'package:calorie_budget/models/profile.dart';
import 'package:calorie_budget/profile_form.dart';
import 'package:calorie_budget/server_error.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  final String uid;
  const Home({Key? key, required this.uid}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  late Stream<Profile?> _profileStream;
  late Stream<FoodLog?> _foodLogStream;
  late Timer _timer;
  Profile? _profile;
  FoodLog? _foodLog;
  DateTime _logDate = DateTime.now();
  DateTime get resetTime => DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, _profile?.resetHour ?? 0, _profile?.resetMinute ?? 0);
  final Duration oneDay = const Duration(days: 1);
  final Duration oneSecond = const Duration(seconds: 1);

  DateTime dateCutOff(DateTime date) => DateTime(date.year, date.month,
      date.day, _profile?.resetHour ?? 24, _profile?.resetMinute ?? 0);

  bool isToday(DateTime date) {
    DateTime startTime =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime endTime = startTime.add(oneDay);
    return date.compareTo(startTime) >= 0 && date.compareTo(endTime) < 0;
  }

  bool isAfterResetTime(DateTime date) => date.compareTo(resetTime) >= 0;

  bool get disableNextDateButton =>
      isToday(_logDate) && !isAfterResetTime(_logDate) ||
      isAfterResetTime(_logDate);

  bool isCurrentLogDate(DateTime date) {
    DateTime now = DateTime.now();
    DateTime startTime = resetTime;
    late DateTime endTime;
    if (now.compareTo(startTime) < 0) {
      endTime = startTime;
      startTime = endTime.subtract(oneDay);
    } else {
      endTime = startTime.add(oneDay);
    }
    return date.compareTo(startTime) >= 0 && date.compareTo(endTime) < 0;
  }

  setDay(DateTime day) {
    _foodLogStream = FoodLog.getStream(widget.uid, day);
    setState(() => _logDate = day);
  }

  @override
  void initState() {
    super.initState();
    _foodLogStream = FoodLog.getStream(widget.uid, _logDate);
    _profileStream = Profile.getStream(widget.uid);
    _profileStream.first.then((profile) {
      _profile = profile;
      if (_logDate.compareTo(resetTime) >= 0) {
        setDay(_logDate.add(oneDay));
      }
    });
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() => _logDate = _logDate.add(oneSecond));
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String formatMonth(int month) {
    switch (month) {
      case 1:
        return 'JAN';
      case 2:
        return 'FEB';
      case 3:
        return 'MAR';
      case 4:
        return 'APR';
      case 5:
        return 'MAY';
      case 6:
        return 'JUN';
      case 7:
        return 'JUL';
      case 8:
        return 'AUG';
      case 9:
        return 'SEP';
      case 10:
        return 'OCT';
      case 11:
        return 'NOV';
      case 12:
        return 'DEC';
      default:
        return '';
    }
  }

  Widget get daySelector => Container(
        color: Theme.of(context).colorScheme.primary,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: () {
                setDay(_logDate.subtract(oneDay));
              },
              icon: Icon(
                Icons.arrow_left,
                size: 30.0,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            SizedBox(
              height: 70.0,
              width: 70.0,
              child: Card(
                child: InkWell(
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: _logDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                      builder: (context, datePicker) => datePicker!,
                    );
                    if (selectedDate != null) setDay(selectedDate);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(formatMonth(_logDate.month)),
                        Expanded(
                          child: Center(
                            child: isCurrentLogDate(_logDate)
                                ? Container(
                                    height: 26.0,
                                    width: 26.0,
                                    decoration: ShapeDecoration(
                                      shape: const CircleBorder(),
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                    ),
                                    child: Center(
                                      child: Text(
                                        _logDate.day.toString(),
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onPrimaryContainer,
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  )
                                : Text(
                                    _logDate.day.toString(),
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primaryContainer,
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                          ),
                        ),
                        Text(_logDate.year.toString()),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            IconButton(
              onPressed: disableNextDateButton
                  ? null
                  : () {
                      setDay(_logDate.add(oneDay));
                    },
              icon: Icon(
                Icons.arrow_right,
                size: 30.0,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Budget'),
        leading: IconButton(
          onPressed: _profile == null
              ? null
              : () => showDialog(
                    context: context,
                    builder: _buildProfileDialog,
                  ),
          icon: const Icon(Icons.person),
        ),
        actions: [SignOutButton()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            showDialog(context: context, builder: _buildFoodEntryDialog),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: Container(
          color: Theme.of(context).colorScheme.primary, child: daySelector),
      body: SafeArea(
        child: StreamBuilder<Profile?>(
          stream: _profileStream,
          builder: (context, profileSnapshot) {
            if (profileSnapshot.hasError) return const ServerError();
            if (profileSnapshot.connectionState == ConnectionState.waiting ||
                !profileSnapshot.hasData) return const Loading();
            _profile = profileSnapshot.data!;
            return StreamBuilder<FoodLog?>(
                stream: _foodLogStream,
                initialData: FoodLog(
                  dateKey: FoodLog.dayKey(dateTime: _logDate),
                ),
                builder: (context, foodLogSnapshot) {
                  bool loadingFoodLog = false;
                  if (foodLogSnapshot.hasError) return const ServerError();
                  if (foodLogSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    loadingFoodLog = true;
                  }
                  if (!foodLogSnapshot.hasData) {
                    _foodLog =
                        FoodLog(dateKey: FoodLog.dayKey(dateTime: _logDate));
                  } else {
                    _foodLog = foodLogSnapshot.data!;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 40.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            'BMR: ${_profile!.bmr!.toStringAsFixed(2)} calories',
                            style: const TextStyle(
                              fontSize: 20.0,
                              color: Colors.lightBlue,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 40.0,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: loadingFoodLog
                              ? const Loading()
                              : Text(
                                  'Balance: ${((isCurrentLogDate(_logDate) ? _profile!.accumulatedCalories : _profile!.bmr! - _profile!.deficitGoal) - _foodLog!.totalCaloriesConsumed).toStringAsFixed(2)} calories',
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.lightBlue,
                                  ),
                                ),
                        ),
                      ),
                      Divider(
                          height: 1.0,
                          color:
                              Theme.of(context).colorScheme.primaryContainer),
                      Expanded(
                        child: _foodLog!.log.isEmpty
                            ? const Center(
                                child: Text(
                                    'You have not entered any food entries yet today.'),
                              )
                            : ListView.builder(
                                itemCount: _foodLog!.log.length,
                                itemBuilder: (context, index) => Dismissible(
                                  key: ValueKey('FoodEntry$index'),
                                  background: Container(
                                    color: Colors.redAccent,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: const [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    setState(
                                        () => _foodLog!.log.removeAt(index));
                                    FoodLog.save(widget.uid, _foodLog!);
                                  },
                                  child: ListTile(
                                    title: Text(
                                        '${_foodLog!.log[index].calories} calories'),
                                    subtitle: _foodLog!.log[index].notes == null
                                        ? null
                                        : Text(_foodLog!.log[index].notes!),
                                    onLongPress: () => showDialog(
                                      context: context,
                                      builder: (dialogContext) =>
                                          _buildFoodEntryDialog(
                                        dialogContext,
                                        index: index,
                                        foodEntry: _foodLog!.log[index],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }

  AlertDialog _buildProfileDialog(BuildContext context) {
    final GlobalKey<ProfileFormState> profileFormKey =
        GlobalKey<ProfileFormState>();
    return AlertDialog(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8.0),
      title: const Text('Edit Profile'),
      content: SizedBox(
        height: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.height * 0.5
            : MediaQuery.of(context).size.height * 0.8,
        width: MediaQuery.of(context).orientation == Orientation.portrait
            ? MediaQuery.of(context).size.width * 0.8
            : MediaQuery.of(context).size.width * 0.4,
        child: ProfileForm(
          key: profileFormKey,
          uid: widget.uid,
          profile: _profile!,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            profileFormKey.currentState!.saveForm();
            Navigator.pop(context, true);
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }

  AlertDialog _buildFoodEntryDialog(BuildContext context,
      {FoodEntry? foodEntry, int? index}) {
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    bool newEntry = foodEntry == null;
    if (newEntry) foodEntry = FoodEntry(calories: 100);
    double initialCalories = foodEntry.calories;
    String? initialNotes = foodEntry.notes;
    return AlertDialog(
      title: Text('${newEntry ? 'Add' : 'Edit'} Food Entry'),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              initialValue: initialCalories.toString(),
              decoration: const InputDecoration(label: Text('Calories')),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                if (double.tryParse(value) != null) {
                  foodEntry!.calories = double.parse(value);
                }
              },
              onSaved: (value) {
                if (value != null && double.tryParse(value) != null) {
                  foodEntry!.calories = double.parse(value);
                }
              },
              validator: (value) =>
                  value != null && double.tryParse(value) != null
                      ? null
                      : 'Please enter a valid number.',
            ),
            TextFormField(
              initialValue: initialNotes,
              decoration: const InputDecoration(label: Text('Notes')),
              onChanged: (value) => foodEntry!.notes = value,
              onSaved: (value) => foodEntry!.notes = value,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            foodEntry!.calories = initialCalories;
            foodEntry.notes = initialNotes;
            Navigator.pop(context, false);
          },
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              formKey.currentState!.save();
            }
            if (index == null) {
              _foodLog!.log.add(foodEntry!);
            } else {
              _foodLog!.log[index] = foodEntry!;
            }
            FoodLog.save(widget.uid, _foodLog!);
            Navigator.pop(context, true);
          },
          child: const Text('SAVE'),
        ),
      ],
    );
  }
}
