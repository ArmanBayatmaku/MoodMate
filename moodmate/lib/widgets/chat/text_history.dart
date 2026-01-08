import 'package:cloud_firestore/cloud_firestore.dart';

/// Build a single text block from chat docs in Firestore.
///
/// Output format:
/// artificialIntelligence: <message>
/// User: <message>
/// artificialIntelligence: <message>

Future<String> buildChatHistoryTextBlock({
  required FirebaseFirestore db,
  required String uid,
  int limit = 500,
}) async {
  final snap = await db
      .collection('users')
      .doc(uid)
      .collection('chat')
      .orderBy('createdAt', descending: false)
      .limit(limit)
      .get();

  final buffer = StringBuffer();

  for (final doc in snap.docs) {
    final data = doc.data();

    final rawText = (data['text'] ?? '').toString();
    if (rawText.trim().isEmpty) continue;

    final senderId = (data['userId'] ?? '').toString();

    final role = (senderId == 'artificialIntelligence')
        ? 'artificialIntelligence'
        : 'User';

    final cleaned = rawText.trim().replaceAll('\r\n', '\n');

    buffer.writeln('$role: $cleaned');
  }

  return buffer.toString().trim();
}
