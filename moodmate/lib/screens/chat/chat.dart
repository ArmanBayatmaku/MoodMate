import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:moodmate/widgets/chat/chat_messages.dart';
import 'package:moodmate/widgets/chat/new_message.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moodmate/screens/home/home.dart';
import 'package:moodmate/screens/tabs.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const bg = Color(0xFFF6F1E9);
  static const appBarBg = Colors.white;
  static const textDark = Color(0xFF1F2A37);
  static const textMuted = Color(0xFF6B7280);
  static const accent = Color(0xFF7F9BB8);
  static const accentSoft = Color(0xFFBFD0E0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        surfaceTintColor: appBarBg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: textDark,
          onPressed: widget.onBack,
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            // TODO maybe add an AI imagE?
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome, color: accent, size: 18),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  'Your Companion',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Always here for you',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                    color: textMuted,
                    height: 1.1,
                  ),
                ),
              ],
            ),
          ],
        ),

        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFEDE7DF),
          ),
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Messages area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Container(
                    color: Colors.transparent,
                    child: const ChatMessages(),
                  ),
                ),
              ),
            ),

            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
              decoration: BoxDecoration(
                color: bg,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.0),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const NewMessage(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
