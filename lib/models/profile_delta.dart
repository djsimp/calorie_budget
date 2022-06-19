import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileDelta {
  double? age;
  double? deficitGoal;
  String? gender;
  double? height;
  double? weight;
  int? resetHour;
  int? resetMinute;
  Timestamp? _timestamp;

  ProfileDelta({
    this.age,
    this.deficitGoal,
    this.gender,
    this.height,
    this.weight,
    this.resetHour,
    this.resetMinute,
    Timestamp? timestamp,
  }) {
    if (timestamp != null) _timestamp = timestamp;
  }

  static String collection = 'profile_deltas';

  Timestamp get timestamp {
    _timestamp ??= Timestamp.now();
    return _timestamp!;
  }

  bool get hasData =>
      age != null ||
      deficitGoal != null ||
      gender != null ||
      height != null ||
      weight != null ||
      resetHour != null ||
      resetMinute != null;

  static Map<String, Object?> toFirestore(
      ProfileDelta? delta, SetOptions? setOptions) {
    if (delta == null) return {};
    return {
      if (delta.age != null) 'age': delta.age,
      if (delta.deficitGoal != null) 'deficit_goal': delta.deficitGoal,
      if (delta.gender != null) 'gender': delta.gender,
      if (delta.height != null) 'height': delta.height,
      if (delta.weight != null) 'weight': delta.weight,
      if (delta.resetHour != null) 'reset_hour': delta.resetHour,
      if (delta.resetMinute != null) 'reset_minute': delta.resetMinute,
      'timestamp': delta.timestamp,
    };
  }

  static ProfileDelta fromFirestore(
      DocumentSnapshot<Map<String, Object?>> snapshot,
      SnapshotOptions? options) {
    var data = snapshot.data() ?? <String, Object?>{};
    return ProfileDelta(
      age: data['age'] as double?,
      deficitGoal: data['deficit_goal'] as double?,
      gender: data['gender'] as String?,
      height: data['height'] as double?,
      weight: data['weight'] as double?,
      resetHour: data['reset_hour'] as int?,
      resetMinute: data['reset_minute'] as int?,
      timestamp: data['timestamp'] as Timestamp,
    );
  }

  static Stream<List<ProfileDelta>?> getStream(String uid) =>
      FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .withConverter(
            fromFirestore: ProfileDelta.fromFirestore,
            toFirestore: ProfileDelta.toFirestore,
          )
          .snapshots()
          .map<List<ProfileDelta>?>(
              (snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  static Stream<List<ProfileDelta>?> getFilteredStream(
          String uid, String filterKey) =>
      FirebaseFirestore.instance
          .collection(collection)
          .where('uid', isEqualTo: uid)
          .where(filterKey, isNull: false)
          .withConverter(
            fromFirestore: ProfileDelta.fromFirestore,
            toFirestore: ProfileDelta.toFirestore,
          )
          .snapshots()
          .map<List<ProfileDelta>?>(
              (snapshot) => snapshot.docs.map((doc) => doc.data()).toList());

  static Future<bool> save(String uid, ProfileDelta delta) {
    return FirebaseFirestore.instance
        .collection(collection)
        .doc(uid)
        .set(ProfileDelta.toFirestore(delta, null))
        .then((_) => true)
        .catchError((_) => false);
  }
}
