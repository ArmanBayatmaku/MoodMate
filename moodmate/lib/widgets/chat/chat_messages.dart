import 'package:moodmate/widgets/chat/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  static const aiUserId = 'artificialintelligence';

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser;

    if (authenticatedUser == null) {
      return const Center(child: Text('Not logged in.'));
    }
    final chatStream = FirebaseFirestore.instance
        .collection('users')
        .doc(authenticatedUser.uid)
        .collection('chatMessages')
        .orderBy('createdAt', descending: true)
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: chatStream,
      builder: (ctx, chatSnapshots) {
        if (chatSnapshots.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatSnapshots.hasError) {
          return const Center(child: Text('Something went wrong...'));
        }

        if (!chatSnapshots.hasData || chatSnapshots.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found.'));
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

            final currentSenderId = (chatMessage['senderId'] ?? '').toString();
            final nextSenderId = nextChatMessage != null
                ? (nextChatMessage['senderId'] ?? '').toString()
                : null;

            final nextUserIsSame = nextSenderId == currentSenderId;

            final isMe = authenticatedUser.uid == currentSenderId;
            final timestamp = (chatMessage['createdAt'] as Timestamp?)
                ?.toDate();

            final String? userImage = chatMessage.containsKey('userImage')
                ? chatMessage['userImage'] as String?
                : null;

            String? username = chatMessage.containsKey('username')
                ? chatMessage['username'] as String?
                : null;

            if (currentSenderId == aiUserId) {
              username ??= 'AI';
            }

            final messageText = (chatMessage['text'] ?? '').toString();

            if (nextUserIsSame) {
              return MessageBubble.next(
                message: messageText,
                isMe: isMe,
                timestamp: timestamp,
              );
            } else {
              return MessageBubble.first(
                userImage: userImage,
                username: username,
                message: messageText,
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
