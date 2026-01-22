import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUtils {
  /// Parses a timestamp from either a Firestore Timestamp or a serialized map
  /// (Cloud Functions serialize Timestamps as {_seconds, _nanoseconds})
  static DateTime parseTimestamp(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is Map) {
      final seconds = value['_seconds'] as int;
      final nanoseconds = value['_nanoseconds'] as int? ?? 0;
      return DateTime.fromMillisecondsSinceEpoch(
        seconds * 1000 + nanoseconds ~/ 1000000,
      );
    }
    throw ArgumentError('Cannot parse timestamp from: $value');
  }
}
