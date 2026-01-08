import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:firebase_ai/firebase_ai.dart';

import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

final model = FirebaseAI.googleAI().generativeModel(model: 'gemini-2.5-flash');

class NewMessage extends StatefulWidget {
  const NewMessage({super.key});

  @override
  State<NewMessage> createState() => _NewMessageState();
}

class _NewMessageState extends State<NewMessage> {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  final _messageController = TextEditingController();

  static const bg = Color(0xFFF6F1E9);
  static const primaryBlue = Color(0xFF7F9BB8);
  static const textBlue = Color(0xFF6F8FB0);
  static const border = Color(0xFFE7DED3);

  static const aiUserId = 'artificialintelligence';

  DocumentReference<Map<String, dynamic>> _userDoc() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw StateError('User not logged in');
    return FirebaseFirestore.instance.collection('users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>> _chatRef() {
    return _userDoc().collection('chatMessages');
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    final ok = await _speechToText.initialize(
      onStatus: (s) => debugPrint('speech status: $s'),
      onError: (e) => debugPrint('speech error: $e'),
    );

    debugPrint('initialize ok: $ok');
    debugPrint('hasPermission: ${_speechToText.hasPermission}');
    debugPrint('isAvailable: ${_speechToText.isAvailable}');

    if (!mounted) return;
    setState(() => _speechEnabled = ok);
  }

  Future<void> _toggleListening() async {
    if (!_speechEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Speech recognition not available')),
      );
      return;
    }

    if (_speechToText.isListening) {
      await _speechToText.stop();
      if (!mounted) return;
      setState(() {});
      return;
    }

    await _speechToText.listen(
      onResult: _onSpeechResult,
      partialResults: true,
      listenMode: ListenMode.dictation,
      // localeId: 'en_GB',
    );

    if (!mounted) return;
    setState(() {});
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    final words = result.recognizedWords;

    setState(() {
      _messageController.value = TextEditingValue(
        text: words,
        selection: TextSelection.collapsed(offset: words.length),
      );
    });
  }

  @override
  void dispose() {
    _speechToText.stop();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submitMessage() async {
    final enteredMessage = _messageController.text;
    if (enteredMessage.trim().isEmpty) return;

    FocusScope.of(context).unfocus();
    _messageController.clear();

    // Stop mic if user sends while listening
    if (_speechToText.isListening) {
      await _speechToText.stop();
      if (mounted) setState(() {});
    }

    final user = FirebaseAuth.instance.currentUser!;

    await _chatRef().add({
      'text': enteredMessage,
      'createdAt': Timestamp.now(),
      'senderId': user.uid,
      'senderType': 'user',
    });

    try {
      final aiReply = await _getAiReply(enteredMessage);

      await _chatRef().add({
        'text': aiReply,
        'createdAt': Timestamp.now(),
        'senderId': aiUserId,
        'senderType': 'ai',
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("AI Error: $e")),
      );
    }
  }

  Future<String> _getAiReply(String currentMessage) async {
    final history = await _getHistoryFromFirestore();
    final chat = model.startChat(history: history);
    final response = await chat.sendMessage(Content.text(currentMessage));
    return response.text ?? "I'm having trouble thinking right now.";
  }

  Future<List<Content>> _getHistoryFromFirestore() async {
    final snapshot = await _chatRef()
        .orderBy('createdAt', descending: false)
        .get();

    final List<Content> history = [];

    if (snapshot.docs.isEmpty) return history;

    for (var i = 0; i < snapshot.docs.length - 1; i++) {
      final data = snapshot.docs[i].data();
      final text = (data['text'] ?? '').toString();

      final senderId = (data['senderId'] ?? '').toString();

      if (senderId == aiUserId) {
        history.add(Content.model([TextPart(text)]));
      } else {
        history.add(Content.text(text));
      }
    }

    return history;
  }

  @override
  Widget build(BuildContext context) {
    final isListening = _speechToText.isListening;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(
                  minHeight: 48,
                  maxHeight: 140,
                ),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                child: Scrollbar(
                  child: TextField(
                    controller: _messageController,
                    keyboardType: TextInputType.multiline,
                    textCapitalization: TextCapitalization.sentences,
                    autocorrect: true,
                    enableSuggestions: true,
                    minLines: 1,
                    maxLines: null,
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
                    ),
                    textAlignVertical: TextAlignVertical.top,
                    scrollPhysics: const BouncingScrollPhysics(),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 10),

            SizedBox(
              height: 48,
              width: 54,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: (isListening ? primaryBlue : primaryBlue).withOpacity(
                    isListening ? 0.55 : 0.35,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: IconButton(
                  icon: Icon(isListening ? Icons.mic : Icons.mic_none_rounded),
                  color: primaryBlue,
                  onPressed: _toggleListening,
                  splashRadius: 22,
                  tooltip: isListening ? 'Stop listening' : 'Speak',
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
