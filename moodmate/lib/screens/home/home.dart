import 'package:flutter/material.dart';
import 'package:moodmate/widgets/home/mood_calendar.dart';
import 'package:moodmate/widgets/home/mood_selector.dart';
import 'package:moodmate/widgets/home/daily_checkin.dart';
import 'package:moodmate/services/daily_checkin_service.dart';
import 'package:moodmate/screens/checkin/daily_checkin.dart';
import 'package:moodmate/controllers/theme_controller.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDay = DateTime.now();

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);
  final checkInService = CheckInService();

  @override
  void initState() {
    super.initState();
    _selectedDay = _norm(_selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;

    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Text(
                    'Good evening, Friend',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: colors.textDark,
                      height: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Track your mood every day',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: colors.accentBlue.withOpacity(0.9),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Mood Calendar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: colors.accentBlue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _CardShell(
                    child: MoodCalendar(
                      selectedDay: _selectedDay,
                      onSelectedDayChanged: (d) =>
                          setState(() => _selectedDay = d),
                    ),
                  ),

                  const SizedBox(height: 14),

                  _CardShell(
                    child: MoodSelector(selectedDay: _selectedDay),
                  ),

                  const SizedBox(height: 14),

                  _CardShell(
                    child: StreamBuilder(
                      stream: checkInService.getForDay(_selectedDay),
                      builder: (context, snapshot) {
                        final completed =
                            snapshot.hasData && snapshot.data!.exists;

                        return DailyCheckInCard(
                          completed: completed,
                          onTap: () async {
                            final saved = await Navigator.of(context)
                                .push<bool>(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DailyCheckInScreen(day: _selectedDay),
                                  ),
                                );
                          },
                        );
                      },
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
    final colors = context.watch<ThemeController>().colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.card.withOpacity(0.75),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.divider),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}
