import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:moodmate/models/home/mood.dart';

class MoodService {
  MoodService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String docIdFor(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(normalize(day));

  CollectionReference<Map<String, dynamic>> moodsRef() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not logged in');
    return _db.collection('users').doc(user.uid).collection('moods');
  }

  Future<void> setMoodForDay(DateTime day, MoodType mood) async {
    final normalized = normalize(day);
    final id = docIdFor(normalized);

    await moodsRef().doc(id).set({
      'date': Timestamp.fromDate(normalized),
      'mood': mood.key,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> moodsForMonth(
    DateTime focusedDay,
  ) {
    final start = DateTime(focusedDay.year, focusedDay.month, 1);
    final endExcl = DateTime(focusedDay.year, focusedDay.month + 1, 1);

    return moodsRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(endExcl))
        .snapshots();
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> moodForDay(DateTime day) {
    final id = docIdFor(day);
    return moodsRef().doc(id).snapshots();
  }
}
