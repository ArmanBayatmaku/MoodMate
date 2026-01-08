import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class CheckInService {
  CheckInService({
    FirebaseAuth? auth,
    FirebaseFirestore? db,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  DateTime normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  String docIdFor(DateTime day) =>
      DateFormat('yyyy-MM-dd').format(normalize(day));

  CollectionReference<Map<String, dynamic>> ref() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not logged in');
    return _db.collection('users').doc(user.uid).collection('checkins');
  }

  Future<void> saveForDay({
    required DateTime day,
    required String mind,
    required String energy,
    required String thoughts,
  }) async {
    final normalized = normalize(day);
    final id = docIdFor(normalized);

    await ref().doc(id).set({
      'date': Timestamp.fromDate(normalized),
      'mind': mind,
      'energy': energy,
      'thoughts': thoughts,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getForDay(DateTime day) {
    return ref().doc(docIdFor(day)).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> checkinsForMonth(
    DateTime focused,
  ) {
    final start = DateTime(focused.year, focused.month, 1);
    final endExcl = DateTime(focused.year, focused.month + 1, 1);

    return ref()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(endExcl))
        .snapshots();
  }
}
