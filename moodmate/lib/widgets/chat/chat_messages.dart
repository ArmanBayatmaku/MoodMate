import 'package:moodmate/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  static const aiUserId = 'artificialintelligence';

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
        }

        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        final loadedMessages = chatSnapshots.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.only(bottom: 40, left: 13, right: 13),
          reverse: true,
          itemCount: loadedMessages.length,
          itemBuilder: (ctx, index) {
            final chatMessage = loadedMessages[index].data();
            final nextChatMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMessageUserId =
                (chatMessage['userId'] ?? '') as String;
            final nextMessageUserId = nextChatMessage != null
                ? (nextChatMessage['userId'] ?? '') as String
                : null;

            final nextUserIsSame = nextMessageUserId == currentMessageUserId;

            final isMe = authenticatedUser.uid == currentMessageUserId;
            final timestamp = (chatMessage['createdAt'] as Timestamp?)
                ?.toDate();

            // AI messages won't store these fields; safely read them only if present.
            final String? userImage = chatMessage.containsKey('userImage')
                ? chatMessage['userImage'] as String?
                : null;

            String? username = chatMessage.containsKey('username')
                ? chatMessage['username'] as String?
                : null;

            // Optional: show "AI" in UI without storing it in Firestore.
            if (currentMessageUserId == aiUserId) {
              username ??= 'AI';
            }

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: (chatMessage['text'] ?? '') as String,
                isMe: isMe,
                timestamp: timestamp,
              );
            } else {
              return MessageBubble.first(
                userImage: userImage,
                username: username,
                message: (chatMessage['text'] ?? '') as String,
                isMe: isMe,
                timestamp: timestamp,
              );
            }
          },
        );
      },
    );
  }
}
