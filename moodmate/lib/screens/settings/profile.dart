import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenScreenState();
}

class _ProfileScreenScreenState extends State<ProfileScreen> {
  static const bg = Color(0xFFF6F1E9);
  static const card = Colors.white;
  static const textDark = Color(0xFF1F2A37);
  static const textMuted = Color(0xFF6B7280);
  static const accent = Color(0xFF7F9BB8);

  static const dotColor = Color(0xFF7F9BB8);

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  late DateTime _focusedDay;
  late DateTime _selectedDay;

  Map<DateTime, Color> _moodColorByDay = {};

  Map<DateTime, bool> _checkinByDay = {};

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _moodsMonthSub;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _checkinsMonthSub;

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
    _moodsMonthSub?.cancel();
    _checkinsMonthSub?.cancel();
    super.dispose();
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
  DateTime _monthStart(DateTime d) => DateTime(d.year, d.month, 1);
  DateTime _monthEndExclusive(DateTime d) => DateTime(d.year, d.month + 1, 1);

  DocumentReference<Map<String, dynamic>> _userDoc() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('User not logged in');
    return _db.collection('users').doc(user.uid);
  }

  CollectionReference<Map<String, dynamic>> _moodsRef() =>
      _userDoc().collection('moods');

  CollectionReference<Map<String, dynamic>> _checkinsRef() =>
      _userDoc().collection('checkins');

  void _listenToMonth(DateTime month) {
    _moodsMonthSub?.cancel();
    _checkinsMonthSub?.cancel();

    final start = _monthStart(month);
    final endExcl = _monthEndExclusive(month);

    _moodsMonthSub = _moodsRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(endExcl))
        .snapshots()
        .listen((snap) {
          final map = <DateTime, Color>{};

          for (final doc in snap.docs) {
            final data = doc.data();
            final ts = data['date'] as Timestamp?;
            if (ts == null) continue;

            final day = _normalize(ts.toDate());

            final colorInt = data['moodColor'];
            if (colorInt is int) {
              map[day] = Color(colorInt);
              continue;
            }

            final moodKey = (data['mood'] ?? '').toString();
            final c = _moodKeyToColor(moodKey);
            if (c != null) map[day] = c;
          }

          if (mounted) setState(() => _moodColorByDay = map);
        });

    _checkinsMonthSub = _checkinsRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('date', isLessThan: Timestamp.fromDate(endExcl))
        .snapshots()
        .listen((snap) {
          final map = <DateTime, bool>{};

          for (final doc in snap.docs) {
            final data = doc.data();
            final ts = data['date'] as Timestamp?;
            if (ts == null) continue;

            final day = _normalize(ts.toDate());
            map[day] = true;
          }

          if (mounted) setState(() => _checkinByDay = map);
        });
  }

  List<int> _eventLoader(DateTime day) {
    final hasCheckin = _checkinByDay[_normalize(day)] ?? false;
    return hasCheckin ? const [1] : const [];
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _selectedMoodStream() {
    final day = _normalize(_selectedDay);
    final next = day.add(const Duration(days: 1));

    return _moodsRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('date', isLessThan: Timestamp.fromDate(next))
        .limit(1)
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _selectedCheckinStream() {
    final day = _normalize(_selectedDay);
    final next = day.add(const Duration(days: 1));

    return _checkinsRef()
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(day))
        .where('date', isLessThan: Timestamp.fromDate(next))
        .limit(1)
        .snapshots();
  }

  Color? _moodKeyToColor(String key) {
    switch (key) {
      case 'great':
        return const Color(0xFFE7F2E7);
      case 'good':
        return const Color(0xFFE3F1FB);
      case 'okay':
        return const Color(0xFFF7F0D8);
      case 'down':
        return const Color(0xFFF6E6D9);
      case 'difficult':
        return const Color(0xFFF4DDE2);
      case 'stressed':
        return const Color(0xFFE9F1FF);
      default:
        return null;
    }
  }

  Future<void> _editMoodSheet() async {
    final options = const <({String key, String label, Color color})>[
      (key: 'great', label: 'Great', color: Color(0xFFE7F2E7)),
      (key: 'good', label: 'Good', color: Color(0xFFE3F1FB)),
      (key: 'okay', label: 'Okay', color: Color(0xFFF7F0D8)),
      (key: 'down', label: 'Down', color: Color(0xFFF6E6D9)),
      (key: 'difficult', label: 'Difficult', color: Color(0xFFF4DDE2)),
      (key: 'stressed', label: 'Stressed', color: Color(0xFFE9F1FF)),
    ];

    final picked =
        await showModalBottomSheet<({String key, String label, Color color})>(
          context: context,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            return Container(
              decoration: const BoxDecoration(
                color: card,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
              child: Column(
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
                    'Edit Mood',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('EEEE, d MMM yyyy').format(_selectedDay),
                    style: const TextStyle(color: textMuted),
                  ),
                  const SizedBox(height: 14),
                  ...options.map((o) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.pop(ctx, o),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: o.color,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.black12),
                          ),
                          child: Text(
                            o.label,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 6),
                ],
              ),
            );
          },
        );

    if (picked == null) return;

    final day = _normalize(_selectedDay);

    final q = await _moodsRef()
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .limit(1)
        .get();

    if (q.docs.isEmpty) {
      await _moodsRef().add({
        'date': Timestamp.fromDate(day),
        'mood': picked.key,
        'moodColor': picked.color.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _moodsRef().doc(q.docs.first.id).update({
        'mood': picked.key,
        'moodColor': picked.color.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }

  Future<void> _editCheckinSheet({
    required String existingMind,
    required String existingEnergy,
    required String existingThoughts,
  }) async {
    final mindCtrl = TextEditingController(text: existingMind);
    final energyCtrl = TextEditingController(text: existingEnergy);
    final thoughtsCtrl = TextEditingController(text: existingThoughts);

    final ok = await showModalBottomSheet<bool>(
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
            child: Column(
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
                  'Edit Check-in',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  DateFormat('EEEE, d MMM yyyy').format(_selectedDay),
                  style: const TextStyle(color: textMuted),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: mindCtrl,
                  decoration: InputDecoration(
                    labelText: "What's on your mind",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: energyCtrl,
                  decoration: InputDecoration(
                    labelText: "Energy level",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: thoughtsCtrl,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: "Thoughts",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(ctx, true),
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
                const SizedBox(height: 6),
              ],
            ),
          ),
        );
      },
    );

    if (ok != true) return;

    final day = _normalize(_selectedDay);

    final q = await _checkinsRef()
        .where('date', isEqualTo: Timestamp.fromDate(day))
        .limit(1)
        .get();

    final payload = {
      'date': Timestamp.fromDate(day),
      'mind': mindCtrl.text.trim(),
      'energy': energyCtrl.text.trim(),
      'thoughts': thoughtsCtrl.text.trim(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (q.docs.isEmpty) {
      await _checkinsRef().add(payload);
    } else {
      await _checkinsRef().doc(q.docs.first.id).update(payload);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('d MMM yyyy').format(_selectedDay);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 20,
                    ),
                    color: textDark,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    onPressed: () => Navigator.of(context).pop(),
                  ),

                  const SizedBox(width: 6),

                  // Title
                  const Text(
                    'Mood & Check-in',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: textDark,
                    ),
                  ),
                ],
              ),
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
                  eventLoader: _eventLoader, // check-in only
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
                      shape: BoxShape.rectangle,
                      border: Border.all(color: accent, width: 2),
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
                    defaultBuilder: (context, day, focusedDay) {
                      final norm = _normalize(day);
                      final moodColor = _moodColorByDay[norm];
                      if (moodColor == null) return null;

                      return _MoodDayCell(
                        day: day,
                        bgColor: moodColor,
                        textColor: textDark,
                        isSelected: isSameDay(_selectedDay, day),
                        accent: accent,
                      );
                    },
                    todayBuilder: (context, day, focusedDay) {
                      final norm = _normalize(day);
                      final moodColor = _moodColorByDay[norm];
                      if (moodColor == null) return null;

                      return _MoodDayCell(
                        day: day,
                        bgColor: moodColor,
                        textColor: textDark,
                        isSelected: isSameDay(_selectedDay, day),
                        accent: accent,
                      );
                    },
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      return Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Center(
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Bottom details
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 12),
                child: ListView(
                  children: [
                    Text(
                      'Selected • $dayLabel',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Mood section
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _selectedMoodStream(),
                      builder: (context, snap) {
                        final hasMood =
                            snap.hasData && snap.data!.docs.isNotEmpty;
                        final moodData = hasMood
                            ? snap.data!.docs.first.data()
                            : null;

                        Color? moodColor;
                        if (moodData != null) {
                          final mc = moodData['moodColor'];
                          if (mc is int) moodColor = Color(mc);
                          if (moodColor == null) {
                            moodColor = _moodKeyToColor(
                              (moodData['mood'] ?? '').toString(),
                            );
                          }
                        }

                        final moodLabel = hasMood
                            ? (moodData?['mood']?.toString() ?? 'Mood')
                            : 'Undefined';

                        return _InfoCard(
                          title: "Mood",
                          child: Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    color: moodColor ?? const Color(0xFFF2EFE9),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Text(
                                    moodLabel,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: textDark,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              OutlinedButton(
                                onPressed: _editMoodSheet,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: textDark,
                                  side: const BorderSide(color: Colors.black12),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 14,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 10),

                    // Check-in section
                    StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _selectedCheckinStream(),
                      builder: (context, snap) {
                        final has = snap.hasData && snap.data!.docs.isNotEmpty;
                        final data = has ? snap.data!.docs.first.data() : null;

                        final mind = (data?['mind'] ?? '').toString();
                        final energy = (data?['energy'] ?? '').toString();
                        final thoughts = (data?['thoughts'] ?? '').toString();

                        return _InfoCard(
                          title: 'Daily Check-in',
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (!has)
                                const Text(
                                  'No check-in for this day.',
                                  style: TextStyle(color: textMuted),
                                )
                              else ...[
                                _kv(
                                  "What's on your mind",
                                  mind.isEmpty ? 'Skipped' : mind,
                                ),
                                const SizedBox(height: 8),
                                _kv(
                                  "Energy",
                                  energy.isEmpty ? 'Skipped' : energy,
                                ),
                                const SizedBox(height: 8),
                                _kv(
                                  "Thoughts",
                                  thoughts.isEmpty ? '—' : thoughts,
                                ),
                              ],
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: OutlinedButton(
                                  onPressed: () => _editCheckinSheet(
                                    existingMind: mind,
                                    existingEnergy: energy,
                                    existingThoughts: thoughts,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: textDark,
                                    side: const BorderSide(
                                      color: Colors.black12,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(has ? 'Edit' : 'Add'),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          k,
          style: const TextStyle(
            color: textMuted,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          v,
          style: const TextStyle(
            color: textDark,
            fontWeight: FontWeight.w800,
            height: 1.25,
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});
  final String title;
  final Widget child;

  static const card = Colors.white;
  static const textDark = Color(0xFF1F2A37);
  static const textMuted = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: textDark,
            ),
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _MoodDayCell extends StatelessWidget {
  const _MoodDayCell({
    required this.day,
    required this.bgColor,
    required this.textColor,
    required this.isSelected,
    required this.accent,
  });

  final DateTime day;
  final Color bgColor;
  final Color textColor;
  final bool isSelected;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: isSelected ? Border.all(color: accent, width: 2) : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
