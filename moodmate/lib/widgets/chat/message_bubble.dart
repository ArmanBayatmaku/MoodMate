import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble.first({
    super.key,
    this.userImage,
    this.username,
    required this.message,
    required this.isMe,
    required this.timestamp,
  }) : isFirstInSequence = true;

  //TODO add user image.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
    required this.timestamp,
  }) : isFirstInSequence = false,
       userImage = null,
       username = null;

  final DateTime? timestamp;
  final bool isFirstInSequence;

  final String? userImage;
  final String? username;

  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (userImage != null)
          Positioned(
            top: 15,
            right: isMe ? 0 : null,
            left: isMe ? null : 0,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImage!),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          //margin: const EdgeInsets.symmetric(horizontal: 46),
          padding: const EdgeInsets.only(bottom: 40),
          child: Row(
            mainAxisAlignment: isMe
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (isFirstInSequence) const SizedBox(height: 18),

                  if (username != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 13, right: 13),
                      child: Text(
                        username!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                  Container(
                    decoration: BoxDecoration(
                      color: isMe
                          ? Colors.grey[300]
                          : theme.colorScheme.secondary.withAlpha(200),
                      borderRadius: BorderRadius.only(
                        topLeft: !isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        topRight: isMe && isFirstInSequence
                            ? Radius.zero
                            : const Radius.circular(12),
                        bottomLeft: const Radius.circular(12),
                        bottomRight: const Radius.circular(12),
                      ),
                    ),
                    constraints: const BoxConstraints(maxWidth: 200),
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 14,
                    ),
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: isMe
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          message,
                          style: TextStyle(
                            height: 1.3,
                            color: isMe
                                ? Colors.black87
                                : theme.colorScheme.onSecondary,
                          ),
                          softWrap: true,
                        ),
                        if (timestamp != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _formatTimestamp(timestamp!),
                            style: TextStyle(
                              fontSize: 10.5,
                              color:
                                  (isMe
                                          ? Colors.black54
                                          : theme.colorScheme.onSecondary)
                                      .withOpacity(0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatTimestamp(DateTime time) {
  final hours = time.hour.toString().padLeft(2, '0');
  final minutes = time.minute.toString().padLeft(2, '0');
  return '$hours:$minutes';
}
