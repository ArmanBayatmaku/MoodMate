import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moodmate/widgets/home/daily_checkin_service.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:moodmate/models/home/mood.dart';
import 'package:moodmate/widgets/home/mood_service.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({
    super.key,
    required this.selectedDay,
    required this.onSelectedDayChanged,
  });

  final DateTime selectedDay;
  final ValueChanged<DateTime> onSelectedDayChanged;

  @override
  State<MoodCalendar> createState() => _MoodCalendarState();
}

class _MoodCalendarState extends State<MoodCalendar> {
  static const textDark = Color(0xFF2E3B4E);
  static const textBlue = Color(0xFF6F8FB0);
  static const borderBlue = Color(0xFF8FB0D6);

  final _service = MoodService();

  late DateTime _focusedDay;
  Map<DateTime, MoodType> _moodByDay = {};
  StreamSubscription? _sub;

  final _checkinService = CheckInService();
  StreamSubscription? _checkinSub;
  Set<DateTime> _checkinDays = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = widget.selectedDay;
    _listenMonth(_focusedDay);
  }

  @override
  void dispose() {
    _sub?.cancel();
    _checkinSub?.cancel();
    super.dispose();
  }

  DateTime _norm(DateTime d) => DateTime(d.year, d.month, d.day);

  void _listenMonth(DateTime focused) {
    _sub?.cancel();
    _checkinSub?.cancel();

    _sub = _service.moodsForMonth(focused).listen((snap) {
      final map = <DateTime, MoodType>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['date'];
        final moodKey = data['mood'];
        //if (ts is! Timestamp) continue;
        final day = _norm(ts.toDate());
        final mood = MoodTypeX.fromKey(moodKey?.toString());
        if (mood != null) map[day] = mood;
      }
      if (mounted) setState(() => _moodByDay = map);
    });

    _checkinSub = _checkinService.checkinsForMonth(focused).listen((snap) {
      final set = <DateTime>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final ts = data['date'];
        //if (ts is! Timestamp) continue;
        set.add(_norm(ts.toDate()));
      }
      if (mounted) setState(() => _checkinDays = set);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(2000, 1, 1),
      lastDay: DateTime(2100, 12, 31),
      focusedDay: _focusedDay,
      calendarFormat: CalendarFormat.month,
      selectedDayPredicate: (d) => isSameDay(widget.selectedDay, d),

      onDaySelected: (selected, focused) {
        widget.onSelectedDayChanged(_norm(selected));
        setState(() => _focusedDay = focused);
      },

      onPageChanged: (focused) {
        setState(() => _focusedDay = focused);
        _listenMonth(focused);
      },

      headerStyle: const HeaderStyle(
        titleCentered: true,
        formatButtonVisible: false,
      ),

      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          color: textBlue.withOpacity(0.85),
          fontWeight: FontWeight.w600,
        ),
        weekendStyle: TextStyle(
          color: textBlue.withOpacity(0.85),
          fontWeight: FontWeight.w600,
        ),
      ),

      calendarBuilders: CalendarBuilders(
        // Chage date background based on the mood
        defaultBuilder: (context, day, focused) {
          final mood = _moodByDay[_norm(day)];
          final hasCheckIn = _checkinDays.contains(_norm(day));
          return _DayCell(
            label: '${day.day}',
            bg: mood?.bgColor,
            isSelected: isSameDay(day, widget.selectedDay),
            hasCheckIn: hasCheckIn,
          );
        },
        todayBuilder: (context, day, focused) {
          final mood = _moodByDay[_norm(day)];
          final hasCheckIn = _checkinDays.contains(_norm(day));
          return _DayCell(
            label: '${day.day}',
            bg: mood?.bgColor,
            isSelected: isSameDay(day, widget.selectedDay),
            hasCheckIn: hasCheckIn,
          );
        },
        selectedBuilder: (context, day, focused) {
          final mood = _moodByDay[_norm(day)];
          final hasCheckIn = _checkinDays.contains(_norm(day));
          return _DayCell(
            label: '${day.day}',
            bg: mood?.bgColor,
            isSelected: true,
            hasCheckIn: hasCheckIn,
          );
        },
        outsideBuilder: (context, day, focused) => const SizedBox.shrink(),
      ),

      calendarStyle: const CalendarStyle(
        outsideDaysVisible: false,
        isTodayHighlighted: false,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.label,
    required this.isSelected,
    this.bg,
    required this.hasCheckIn,
  });

  final bool hasCheckIn;
  final String label;
  final bool isSelected;
  final Color? bg;

  static const textDark = Color(0xFF2E3B4E);
  static const borderBlue = Color(0xFF8FB0D6);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg ?? Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              border: isSelected
                  ? Border.all(color: borderBlue, width: 2)
                  : null,
            ),
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: textDark,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 3,
          child: Opacity(
            opacity: hasCheckIn ? 1 : 0,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: const Color(0xFF8FB0D6),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
