import 'package:calorie_budget/models/profile_delta.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile {
  double? age;
  late double deficitGoal;
  String? gender;
  double? height;
  double? weight;
  late int resetHour;
  late int resetMinute;

  Profile({
    this.age,
    this.deficitGoal = 500.0,
    this.gender,
    this.height,
    this.weight,
    this.resetHour = 0,
    this.resetMinute = 0,
  });

  static String collection = 'profiles';

  double? get bmr =>
      age == null || gender == null || height == null || weight == null
          ? null
          : gender == "Male"
              ? 66.47 + 6.24 * weight! + 12.7 * height! - 6.755 * age!
              : 655.1 + 4.35 * weight! + 4.7 * height! - 4.7 * age!;

  double get dailyAllottedCalories => bmr == null ? 0.0 : bmr! - deficitGoal;

  double get accumulatedCalories {
    DateTime now = DateTime.now();
    DateTime resetTime = DateTime(
      now.year,
      now.month,
      now.day,
      resetHour,
      resetMinute,
    );
    if (now.compareTo(resetTime) < 0) {
      resetTime = resetTime.subtract(const Duration(days: 1));
    }
    return dailyAllottedCalories *
        (now.difference(resetTime).inSeconds /
            const Duration(hours: 24).inSeconds);
  }

  void update(ProfileDelta delta) {
    if (delta.age != null) age = delta.age;
    if (delta.deficitGoal != null) deficitGoal = delta.deficitGoal!;
    if (delta.gender != null) gender = delta.gender;
    if (delta.height != null) height = delta.height;
    if (delta.weight != null) weight = delta.weight;
    if (delta.resetHour != null) resetHour = delta.resetHour!;
    if (delta.resetMinute != null) resetMinute = delta.resetMinute!;
  }

  static Map<String, Object?> toFirestore(
      Profile? profile, SetOptions? setOptions) {
    if (profile == null) return {};
    return {
      'age': profile.age,
      'deficit_goal': profile.deficitGoal,
      'gender': profile.gender,
      'height': profile.height,
      'weight': profile.weight,
      'reset_hour': profile.resetHour,
      'reset_minute': profile.resetMinute,
    };
  }

  static Profile? fromFirestore(DocumentSnapshot<Map<String, Object?>> snapshot,
      SnapshotOptions? options) {
    var data = snapshot.data()!;
    if (data['age'] == null ||
        data['deficit_goal'] == null ||
        data['gender'] == null ||
        data['height'] == null ||
        data['weight'] == null) return null;
    return Profile(
      age: data['age'] as double,
      deficitGoal: data['deficit_goal'] as double,
      gender: data['gender'] as String,
      height: data['height'] as double,
      weight: data['weight'] as double,
      resetHour: data['reset_hour'] as int? ?? 0,
      resetMinute: data['reset_minute'] as int? ?? 0,
    );
  }

  static Stream<Profile?> getStream(String uid) => FirebaseFirestore.instance
      .collection(collection)
      .doc(uid)
      .withConverter(
        fromFirestore: fromFirestore,
        toFirestore: toFirestore,
      )
      .snapshots()
      .map<Profile?>((snapshot) => snapshot.data());

  static Future<bool?> save(String uid, ProfileDelta delta) async {
    DocumentReference<Map<String, Object?>> profileRef =
        FirebaseFirestore.instance.collection(collection).doc(uid);
    DocumentReference<Map<String, Object?>> deltaRef = FirebaseFirestore
        .instance
        .collection(Profile.collection)
        .doc(uid)
        .collection(ProfileDelta.collection)
        .doc(delta.timestamp.toDate().toIso8601String());
    Profile? profile = await profileRef
        .withConverter(fromFirestore: fromFirestore, toFirestore: toFirestore)
        .get()
        .then((snapshot) => snapshot.data());
    profile ??= Profile();
    if (!delta.hasData) {
      return null;
    } // return null when no change has been made to profile
    profile.update(delta);
    WriteBatch batch = FirebaseFirestore.instance.batch();
    batch.set<Map<String, Object?>>(
        profileRef, Profile.toFirestore(profile, null));
    batch.set<Map<String, Object?>>(
        deltaRef, ProfileDelta.toFirestore(delta, null));
    return await batch.commit().then((_) => true, onError: (_) => false);
  }
}
