import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:moodmate/screens/settings/about.dart';
import 'package:moodmate/screens/settings/help.dart';

final user = FirebaseAuth.instance.currentUser;
final email = user?.email;

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const bg = Color(0xFFF6F1E9);
  static const card = Colors.white;
  static const textDark = Color(0xFF2E3B4E);
  static const textMuted = Color(0xFF8A96A8);
  static const accentBlue = Color(0xFF7F9BB8);
  static const divider = Color(0xFFE3DED6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 26, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                      color: textDark,
                      height: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Customize your experience',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Profile card
                  _CardShell(
                    child: _SettingsRow(
                      icon: Icons.person_outline,
                      iconColor: accentBlue,
                      title: '${email}',
                      subtitle: 'View Profile',
                      onTap: () {
                        // TODO: navigate to profile
                      },
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Group card
                  _CardShell(
                    child: Column(
                      children: [
                        _SettingsRow(
                          icon: Icons.text_fields,
                          iconColor: accentBlue,
                          title: 'Text Size',
                          onTap: () {
                            // TODO
                          },
                        ),
                        _DividerLine(),
                        _SettingsRow(
                          icon: Icons.palette_outlined,
                          iconColor: accentBlue,
                          title: 'Color Themes',
                          onTap: () {
                            // TODO
                          },
                        ),
                        _DividerLine(),
                        _SettingsRow(
                          icon: Icons.notifications_none,
                          iconColor: accentBlue,
                          title: 'Notifications',
                          onTap: () {
                            // TODO
                          },
                        ),
                        _DividerLine(),
                        _SettingsRow(
                          icon: Icons.help_outline,
                          iconColor: accentBlue,
                          title: 'Help & Support',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const HelpScreen(),
                              ),
                            );
                          },
                        ),
                        _DividerLine(),
                        _SettingsRow(
                          icon: Icons.info_outline,
                          iconColor: accentBlue,
                          title: 'About',
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (ctx) => const AboutScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Sign out
                  _CardShell(
                    child: _SettingsRow(
                      icon: Icons.logout,
                      iconBg: const Color(0xFFF6E7E7),
                      iconColor: const Color(0xFFCF6E6E),
                      title: 'Sign Out',
                      titleColor: const Color(0xFFCF6E6E),
                      showChevron: false,
                      onTap: () {
                        FirebaseAuth.instance.signOut();
                      },
                    ),
                  ),

                  const SizedBox(height: 34),

                  Text(
                    'Companion App v1.0.0',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textMuted.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 10),
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

  static const card = Colors.white;
  static const divider = Color(0xFFE3DED6);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: divider),
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

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  static const divider = Color(0xFFE3DED6);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.only(left: 68, right: 6),
      color: divider.withOpacity(0.8),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.iconBg,
    this.iconColor,
    this.titleColor,
    this.showChevron = true,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  final Color? iconBg;
  final Color? iconColor;
  final Color? titleColor;
  final bool showChevron;

  static const textDark = Color(0xFF2E3B4E);
  static const textMuted = Color(0xFF8A96A8);
  static const defaultIconBg = Color(0xFFF1F4F7);

  @override
  Widget build(BuildContext context) {
    final resolvedIconBg = iconBg ?? defaultIconBg;
    final resolvedIconColor = iconColor ?? const Color(0xFF7F9BB8);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: resolvedIconBg,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Icon(icon, color: resolvedIconColor, size: 26),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: titleColor ?? textDark,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: textMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            if (showChevron)
              const Icon(
                Icons.chevron_right,
                size: 30,
                color: textMuted,
              ),
          ],
        ),
      ),
    );
  }
}
