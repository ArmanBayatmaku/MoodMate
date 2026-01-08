import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<CalendarScreen> {
  static const bg = Color(0xFFF6F1E9);
  static const card = Colors.white;
  static const textDark = Color(0xFF1F2A37);
  static const textMuted = Color(0xFF6B7280);
  static const accent = Color(0xFF7F9BB8);
  static const outline = Color(0xFF9BB47A);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late DateTime _focusedDay;
  late DateTime _selectedDay;
  Map<DateTime, int> _countsByDay = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _monthSub;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _focusedDay = DateTime(now.year, now.month, now.day);
    _selectedDay = DateTime(now.year, now.month, now.day);

    _listenToMonth(_focusedDay);
  }

  @override
  void dispose() {
    _monthSub?.cancel();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _monthEndExclusive(DateTime d) => DateTime(d.year, d.month + 1, 1);

  CollectionReference<Map<String, dynamic>> _remindersRef() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('User not logged in');
    }
    return _db.collection('users').doc(user.uid).collection('reminders');
  }

  void _listenToMonth(DateTime month) {
    _monthSub?.cancel();

    final start = _monthStart(month);
    final endExcl = _monthEndExclusive(month);

    _monthSub = _remindersRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(endExcl))
        .snapshots()
        .listen((snap) {
          final map = <DateTime, int>{};
          for (final doc in snap.docs) {
            final ts = doc.data()['date'] as Timestamp?;
            if (ts == null) continue;
            final day = _normalize(ts.toDate());
            map[day] = (map[day] ?? 0) + 1;
          }
          if (mounted) {
            setState(() => _countsByDay = map);
          }
        });
  }

  List<int> _eventLoader(DateTime day) {
    final count = _countsByDay[_normalize(day)] ?? 0;
    if (count <= 0) return const [];
    return List<int>.generate(count, (i) => i);
  }

  Future<void> _addReminderDialog() async {
    final titleCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    TimeOfDay? pickedTime;

    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: Container(
            decoration: const BoxDecoration(
              color: card,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: StatefulBuilder(
              builder: (ctx, setSheetState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 44,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.black12,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add Reminder',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Selected day display
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        DateFormat('EEEE, d MMM yyyy').format(_selectedDay),
                        style: const TextStyle(color: textMuted),
                      ),
                    ),
                    const SizedBox(height: 12),

                    TextField(
                      controller: titleCtrl,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: noteCtrl,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Note (optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final t = await showTimePicker(
                                context: ctx,
                                initialTime: TimeOfDay.now(),
                              );
                              if (t != null) {
                                setSheetState(() => pickedTime = t);
                              }
                            },
                            icon: const Icon(Icons.access_time),
                            label: Text(
                              pickedTime == null
                                  ? 'Add time (optional)'
                                  : 'Time: ${pickedTime!.format(ctx)}',
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: textDark,
                              side: const BorderSide(color: Colors.black12),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final title = titleCtrl.text.trim();
                              if (title.isEmpty) return;

                              final normalizedDay = _normalize(_selectedDay);

                              final timeStr = pickedTime == null
                                  ? null
                                  : pickedTime!.hour.toString().padLeft(
                                          2,
                                          '0',
                                        ) +
                                        ':' +
                                        pickedTime!.minute.toString().padLeft(
                                          2,
                                          '0',
                                        );

                              await _remindersRef().add({
                                'title': title,
                                'note': noteCtrl.text.trim(),
                                'date': Timestamp.fromDate(normalizedDay),
                                'time': timeStr,
                                'createdAt': FieldValue.serverTimestamp(),
                              });

                              if (ctx.mounted) Navigator.pop(ctx, true);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: const Text('Save'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                  ],
                );
              },
            ),
          ),
        );
      },
    );

    if (result == true && mounted) {
      FocusScope.of(context).unfocus();
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _selectedDayStream() {
    final day = _normalize(_selectedDay);
    final next = day.add(const Duration(days: 1));

    return _remindersRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('date', isLessThan: Timestamp.fromDate(next))
        .orderBy('date')
        .snapshots();
  }

  Future<void> _deleteReminder(String docId) async {
    await _remindersRef().doc(docId).delete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            const Text(
              'Reminders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Manage your appointments and reminders',
              style: TextStyle(color: textMuted),
            ),
            const SizedBox(height: 14),

            // Calendar card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
                child: TableCalendar(
                  firstDay: DateTime(2000, 1, 1),
                  lastDay: DateTime(2100, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (d) => isSameDay(_selectedDay, d),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = _normalize(selected);
                      _focusedDay = focused;
                    });
                  },
                  onPageChanged: (focused) {
                    setState(() => _focusedDay = focused);
                    _listenToMonth(focused);
                  },
                  eventLoader: _eventLoader,
                  calendarFormat: CalendarFormat.month,
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false,
                    leftChevronIcon: const Icon(Icons.chevron_left),
                    rightChevronIcon: const Icon(Icons.chevron_right),
                    titleTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekdayStyle: TextStyle(color: textMuted),
                    weekendStyle: TextStyle(color: textMuted),
                  ),
                  calendarStyle: CalendarStyle(
                    isTodayHighlighted: false,
                    outsideDaysVisible: false,
                    defaultDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    weekendDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    outsideDecoration: const BoxDecoration(
                      shape: BoxShape.rectangle,
                    ),
                    todayDecoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    selectedDecoration: BoxDecoration(
                      color: bg,
                      border: Border.all(color: outline, width: 2),
                      borderRadius: BorderRadius.circular(14),
                    ),

                    selectedTextStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                    defaultTextStyle: const TextStyle(color: textDark),
                    weekendTextStyle: const TextStyle(color: textDark),
                  ),

                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final count = events.length;
                      if (count <= 0) return null;

                      final dots = (count > 3) ? 3 : count;
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(dots, (_) {
                            return Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 1.4,
                              ),
                              decoration: const BoxDecoration(
                                color: outline,
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Add Reminder button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _addReminderDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Reminder'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textDark,
                    side: const BorderSide(color: Colors.black12),
                    backgroundColor: const Color(0xFFF2EFE9),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Selected day list
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _selectedDayStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snap.hasData || snap.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'No reminders for ${DateFormat('d MMM').format(_selectedDay)}',
                          style: const TextStyle(color: textMuted),
                        ),
                      );
                    }

                    final docs = snap.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Reminders • ${DateFormat('d MMM yyyy').format(_selectedDay)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: textDark,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ListView.separated(
                            itemCount: docs.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final doc = docs[i];
                              final data = doc.data();

                              final title = (data['title'] ?? '').toString();
                              final note = (data['note'] ?? '').toString();
                              final time = (data['time'] ?? '').toString();

                              return Container(
                                decoration: BoxDecoration(
                                  color: card,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 8,
                                      offset: Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: ListTile(
                                  title: Text(
                                    title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textDark,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (time.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            time,
                                            style: const TextStyle(
                                              color: textMuted,
                                            ),
                                          ),
                                        ),
                                      if (note.isNotEmpty)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: Text(
                                            note,
                                            style: const TextStyle(
                                              color: textMuted,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () => _deleteReminder(doc.id),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
