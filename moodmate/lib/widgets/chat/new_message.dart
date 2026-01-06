import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodmate/widgets/chat/text_history.dart';

import 'package:firebase_ai/firebase_ai.dart';
import 'package:moodmate/widgets/chat/text_history.dart';

final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final _messageController = TextEditingController();

  static const bg = Color(0xFFF6F1E9);
  static const primaryBlue = Color(0xFF7F9BB8);
  static const textBlue = Color(0xFF6F8FB0);
  static const border = Color(0xFFE7DED3);

  static const aiUserId = 'artificialintelligence';

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text;

    if (enteredMessage.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    _messageController.clear();

    final user = FirebaseAuth.instance.currentUser!;
    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'userId': user.uid,
    });

    final aiReply = await _getAiReply(enteredMessage);

    await FirebaseFirestore.instance.collection('chat').add({
      'text': aiReply,
      'createdAt': Timestamp.now(),
      'userId': aiUserId,
    });
  }

  Future<String> _textHistory() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final textBlock = await buildChatHistoryTextBlock(
      db: FirebaseFirestore.instance,
      uid: uid,
    );

    return textBlock;
  }

  Future<String> _aiAnswer() async {
    final history = await _textHistory();
    final prompt = [
      Content.text(
        'You are a chatbot that is built to act as a mood tracker/diary + reminder for elderly. your message history with this user is ${history}. Keep the history in mind but focus on the last message the most.',
      ),
    ];

    final response = await model.generateContent(prompt);
    final answer = response.text;

    print('IM HEREEEEEEEEEEEEE ${answer}');

    return answer ?? "Error. Please try again later.";
  }

  Future<String> _getAiReply(String userText) async {
    final answer = await _aiAnswer();
    return answer;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  autocorrect: true,
                  enableSuggestions: true,
                  minLines: 1,
                  maxLines: 4,
                  cursorColor: primaryBlue,
                  style: const TextStyle(
                    fontSize: 14.5,
                    color: Color(0xFF1F2A37),
                    height: 1.25,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    hintStyle: TextStyle(
                      color: textBlue.withOpacity(0.65),
                      fontWeight: FontWeight.w500,
                    ),
                    border: InputBorder.none,
                    isCollapsed: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  onSubmitted: (_) => _submitMessage(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              height: 48,
              width: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: IconButton(
                  icon: const Icon(Icons.send_rounded),
                  color: primaryBlue,
                  onPressed: _submitMessage,
                  splashRadius: 22,
                  tooltip: 'Send',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
