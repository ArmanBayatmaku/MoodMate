import 'package:flutter/material.dart';
import 'package:moodmate/widgets/home/daily_checkin_service.dart';

class DailyCheckInScreen extends StatefulWidget {
  const DailyCheckInScreen({super.key, required this.day});
  final DateTime day;

  @override
  State<DailyCheckInScreen> createState() => _DailyCheckInScreenState();
}

class _DailyCheckInScreenState extends State<DailyCheckInScreen> {
  static const bg = Color(0xFFF6F1E9);
  static const textDark = Color(0xFF1F2A37);
  static const textBlue = Color(0xFF6F8FB0);
  static const primaryBlue = Color(0xFF7F9BB8);
  static const border = Color(0xFFE7DED3);

  final _service = CheckInService();
  final _thoughtsCtrl = TextEditingController();

  String? _mind;
  String? _energy;

  int _step = 0; // 0 = mind, 1 = energy, 2 = thoughts

  @override
  void dispose() {
    _thoughtsCtrl.dispose();
    super.dispose();
  }

  Future<void> _askOther(BuildContext context, String title) async {
    final ctrl = TextEditingController();
    bool canSubmit = false;

    final res = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return Dialog(
              backgroundColor: const Color(0xFFF6F1E9),
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 24,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 12, 14),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Your Response',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1F2A37),
                              ),
                            ),
                          ),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () => Navigator.pop(ctx),
                            child: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Icon(
                                Icons.close,
                                size: 22,
                                color: Color(0xFF2E3B4E),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(height: 1, color: const Color(0xFFE7DED3)),

                    // Body
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Please type your own response:',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8A96A8),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Big input box
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(22),
                              border: Border.all(
                                color: const Color(0xFF8FB0D6),
                                width: 3,
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            child: TextField(
                              controller: ctrl,
                              autofocus: true,
                              minLines: 4,
                              maxLines: 6,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                hintText: 'Type here...',
                                hintStyle: TextStyle(
                                  color: Color(0xFF9AA6B2),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onChanged: (v) {
                                final ok = v.trim().isNotEmpty;
                                if (ok != canSubmit) {
                                  setDialogState(() => canSubmit = ok);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Divider
                    Container(height: 1, color: const Color(0xFFE7DED3)),

                    // Actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                      child: Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: canSubmit
                                  ? () => Navigator.pop(ctx, ctrl.text.trim())
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7F9BB8),
                                disabledBackgroundColor: const Color(
                                  0xFF7F9BB8,
                                ).withOpacity(0.45),
                                foregroundColor: Colors.white,
                                disabledForegroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                              ),
                              child: const Text(
                                'Submit',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF7A8798),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    if (res != null && res.trim().isNotEmpty) {
      setState(() {
        if (title.contains('mind')) {
          _mind = 'other: $res';
        } else {
          _energy = 'other: $res';
        }
      });
    }
  }

  bool get _canGoNext {
    if (_step == 0) return _mind != null;
    if (_step == 1) return _energy != null;
    return true;
  }

  void _next() {
    if (!_canGoNext) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an option to continue.')),
      );
      return;
    }
    setState(() => _step = (_step + 1).clamp(0, 2));
  }

  void _back() {
    setState(() => _step = (_step - 1).clamp(0, 2));
  }

  Future<void> _save() async {
    if (_mind == null || _energy == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please answer the first two questions.')),
      );
      return;
    }

    await _service.saveForDay(
      day: widget.day,
      mind: _mind!,
      energy: _energy!,
      thoughts: _thoughtsCtrl.text.trim(),
    );

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final mindOptions = const [
      ('family', 'Family and relationships'),
      ('health', 'Health and wellness'),
      ('work', 'Work or activities'),
      ('easy', 'Just taking it easy'),
    ];

    final energyOptions = const [
      ('low', 'Low energy'),
      ('medium', 'Okay / steady'),
      ('high', 'High energy'),
    ];

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 24),
              child: Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: primaryBlue.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Icon(Icons.auto_awesome, color: textBlue, size: 28),
                  ),
                  const SizedBox(height: 16),

                  // Progress
                  _ProgressDots(step: _step),
                  const SizedBox(height: 16),

                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 180),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _buildStep(
                        key: ValueKey(_step),
                        mindOptions: mindOptions,
                        energyOptions: energyOptions,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Bottom controls
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _step == 0
                              ? () => Navigator.pop(context, false)
                              : _back,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: textDark,
                            side: const BorderSide(color: border),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(_step == 0 ? 'Skip' : 'Back'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _step == 2
                              ? _save
                              : (_canGoNext ? _next : null),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue.withOpacity(0.9),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: Text(
                            _step == 2 ? 'Save Check-in' : 'Next',
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required Key key,
    required List<(String, String)> mindOptions,
    required List<(String, String)> energyOptions,
  }) {
    if (_step == 0) {
      // Q1
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'What has been on your mind today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Take a moment to reflect',
            style: TextStyle(color: textBlue.withOpacity(0.85)),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                ...mindOptions.map(
                  (opt) => _ChoiceTile(
                    label: opt.$2,
                    selected: _mind == opt.$1,
                    onTap: () => setState(() => _mind = opt.$1),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                _ChoiceTile(
                  label: 'Other',
                  selected: _mind?.startsWith('other:') ?? false,
                  onTap: () => _askOther(context, 'other mind'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    if (_step == 1) {
      // Q2
      return Column(
        key: key,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'How is your energy today?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be honest — there’s no wrong answer',
            style: TextStyle(color: textBlue.withOpacity(0.85)),
          ),
          const SizedBox(height: 30),
          Expanded(
            child: ListView(
              children: [
                ...energyOptions.map(
                  (opt) => _ChoiceTile(
                    label: opt.$2,
                    selected: _energy == opt.$1,
                    onTap: () => setState(() => _energy = opt.$1),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                _ChoiceTile(
                  label: 'Other',
                  selected: _energy?.startsWith('other:') ?? false,
                  onTap: () => _askOther(context, 'other energy'),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Q3 thoughts
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'Any thoughts you want to write down?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: textDark,
              height: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'This is your private diary space',
            style: TextStyle(color: textBlue.withOpacity(0.85)),
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: TextField(
              controller: _thoughtsCtrl,
              expands: true,
              maxLines: null,
              minLines: null,
              textAlignVertical: TextAlignVertical.top,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Write anything you want...',
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.step});
  final int step;

  static const primaryBlue = Color(0xFF7F9BB8);

  @override
  Widget build(BuildContext context) {
    Widget dot(bool active) => AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: active ? 18 : 8,
      height: 8,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: active ? primaryBlue : primaryBlue.withOpacity(0.25),
        borderRadius: BorderRadius.circular(999),
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        dot(step == 0),
        dot(step == 1),
        dot(step == 2),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  const _ChoiceTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const textDark = Color(0xFF1F2A37);
  static const primaryBlue = Color(0xFF7F9BB8);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: selected ? primaryBlue : const Color(0xFFE7DED3),
                  width: selected ? 2 : 1,
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textDark,
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          height: 20,
        ),
      ],
    );
  }
}
