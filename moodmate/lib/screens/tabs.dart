import 'package:flutter/material.dart';
import 'package:moodmate/screens/calendar/calendar.dart';
import 'package:moodmate/screens/chat/chat.dart';
import 'package:moodmate/screens/home/home.dart';
import 'package:moodmate/screens/settings/settings.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 1;
  int _lastPageIndex = 1; // ⬅️ remember previous tab

  void _onTabSelected(int index) {
    if (index != 2) {
      _lastPageIndex = index; // ⬅️ only store non-chat tabs
    }

    setState(() {
      _selectedPageIndex = index;
    });
  }

  void goBackFromChat() {
    setState(() {
      _selectedPageIndex = _lastPageIndex;
    });
  }

  //final List<Widget> _pages = [
  //  CalendarScreen(),
  //  HomeScreen(),
  //  ChatScreen(onBack: goBackFromChat),
  //  SettingsScreen(),
  //];

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1E9);
    const primaryBlue = Color(0xFF7F9BB8);
    const textBlue = Color(0xFF6F8FB0);

    final bool isChat = _selectedPageIndex == 2;

    final pages = [
      const CalendarScreen(),
      const HomeScreen(),
      ChatScreen(onBack: goBackFromChat), // ✅ now legal
      const SettingsScreen(),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: pages[_selectedPageIndex],
      ),

      // ⬇️ HIDE bottom tab only on Chat screen
      bottomNavigationBar: isChat
          ? null
          : Container(
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
                onTap: _onTabSelected,
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
