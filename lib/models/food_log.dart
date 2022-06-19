import 'package:calorie_budget/models/profile.dart';
import 'package:intl/intl.dart';
import 'package:calorie_budget/models/food_entry.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodLog {
  late List<FoodEntry> log;
  String? _dateKey;

  FoodLog({List<FoodEntry>? initialLog, String? dateKey}) {
    log = initialLog ?? [];
    _dateKey = dateKey;
  }

  static String collection = 'food_log';

  double get totalCaloriesConsumed {
    double calories = 0;
    for (var foodEntry in log) {
      calories += foodEntry.calories;
    }
    return calories;
  }

  String get dateKey => _dateKey ?? dayKey();

  static String dayKey({DateTime? dateTime}) =>
      DateFormat('yyyy_MM_dd').format(dateTime ?? DateTime.now());

  static Map<String, Object?> toFirestore(
      FoodLog? foodLog, SetOptions? setOptions) {
    if (foodLog == null) return {};
    return foodLog.log
        .map((foodEntry) => FoodEntry.toFirestore(foodEntry, setOptions))
        .toList()
        .asMap()
        .map<String, Object?>((key, value) => MapEntry(key.toString(), value));
  }

  static FoodLog? fromFirestore(DocumentSnapshot<Map<String, Object?>> snapshot,
      SnapshotOptions? options) {
    if (snapshot.data() == null) return null;
    return FoodLog(
      initialLog: snapshot.data()!.entries.map((entry) {
        Map<String, Object?> map = entry.value! as Map<String, Object?>;
        return FoodEntry(
          timestamp: DateTime.parse(map['timestamp'] as String),
          calories: map['calories'] as double,
          notes: map['notes'] as String?,
        );
      }).toList(),
      dateKey: snapshot.id,
    );
  }

  static Stream<FoodLog?> getStream(String uid, DateTime day) =>
      FirebaseFirestore.instance
          .collection(Profile.collection)
          .doc(uid)
          .collection(collection)
          .doc(dayKey(dateTime: day))
          .withConverter(
            fromFirestore: FoodLog.fromFirestore,
            toFirestore: FoodLog.toFirestore,
          )
          .snapshots()
          .map<FoodLog?>((snapshot) => snapshot.data());

  static Future<bool> save(String uid, FoodLog foodLog) {
    return FirebaseFirestore.instance
        .collection(Profile.collection)
        .doc(uid)
        .collection(collection)
        .doc(foodLog.dateKey)
        .set(FoodLog.toFirestore(foodLog, null))
        .then((_) => true)
        .catchError((_) => false);
  }

  @override
  String toString() {
    return log.isEmpty
        ? '[]'
        : '[\n${log.map((e) => '{timestamp: ${e.timestamp}, calories: ${e.calories}, notes: ${e.notes}},\n')}]';
  }
}
