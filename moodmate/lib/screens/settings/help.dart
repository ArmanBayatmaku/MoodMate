import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const bg = Color(0xFFF6F1E9);
  static const card = Colors.white;
  static const textDark = Color(0xFF2E3B4E);
  static const textMuted = Color(0xFF8A96A8);
  static const accentBlue = Color(0xFF7F9BB8);
  static const border = Color(0xFFE3DED6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        foregroundColor: textDark,
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FAQ Card
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Frequently Asked Questions',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 18),

                        _Question(
                          question: 'How do I change my mood entry?',
                          answer:
                              'You can view and edit both the mood and checkin entries through the profile page in the settings.',
                        ),
                        SizedBox(height: 14),

                        _Question(
                          question: 'Is my data private?',
                          answer:
                              'Yes, all your data is encrypted and private. We never share your information.',
                        ),
                        SizedBox(height: 14),

                        _Question(
                          question: 'Can I skip the daily check-in?',
                          answer:
                              'Absolutely! You can skip any day. There’s no pressure to check in every day.',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Contact Us Card
                  _CardShell(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'If you need further help, feel free to reach out:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: textMuted,
                          ),
                        ),
                        const SizedBox(height: 14),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F2F2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.email_outlined,
                                color: accentBlue,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'no@support.com',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: textDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: HelpScreen.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Question extends StatelessWidget {
  const _Question({
    required this.question,
    required this.answer,
  });

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: HelpScreen.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: HelpScreen.textMuted,
            height: 1.35,
          ),
        ),
      ],
    );
  }
}
