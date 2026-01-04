import 'package:flutter/material.dart';
import 'package:moodmate/screens/calendar.dart';
import 'package:moodmate/screens/chat.dart';
import 'package:moodmate/screens/home.dart';
import 'package:moodmate/screens/settings.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 1; // Home selected by default (matches screenshot)

  final List<Widget> _pages = const [
    CalendarScreen(), // Calendar (replace later)
    HomeScreen(), // Home
    ChatScreen(), // Chat (replace later)
    SettingsScreen(), // Settings (replace later)
  ];

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1E9);
    const primaryBlue = Color(0xFF7F9BB8);
    const textBlue = Color(0xFF6F8FB0);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        // keep SafeArea so content doesn't clash with notches,
        // and let the bottom bar sit at the bottom
        child: _pages[_selectedPageIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          border: const Border(
            top: BorderSide(color: Color(0xFFE7DED3)),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedPageIndex,
          onTap: (i) => setState(() => _selectedPageIndex = i),
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: primaryBlue,
          unselectedItemColor: textBlue.withOpacity(0.7),
          selectedFontSize: 11.5,
          unselectedFontSize: 11.5,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month_outlined),
              activeIcon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.chat_bubble_outline),
              activeIcon: Icon(Icons.chat_bubble),
              label: 'Chat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
