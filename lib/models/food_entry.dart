import 'package:cloud_firestore/cloud_firestore.dart';

class FoodEntry {
  late DateTime _timestamp;
  double calories;
  String? notes;

  FoodEntry({DateTime? timestamp, required this.calories, this.notes}) {
    _timestamp = timestamp ?? DateTime.now();
  }

  DateTime get timestamp => _timestamp;

  static Map<String, Object?>? toFirestore(
      FoodEntry? foodEntry, SetOptions? setOptions) {
    if (foodEntry == null) return null;
    return {
      'timestamp': foodEntry.timestamp.toString(),
      'calories': foodEntry.calories,
      if (foodEntry.notes != null) 'notes': foodEntry.notes!,
    };
  }
}
