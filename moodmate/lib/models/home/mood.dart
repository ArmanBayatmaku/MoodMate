import 'package:flutter/material.dart';

enum MoodType { great, good, okay, down, difficult, stressed }

extension MoodTypeX on MoodType {
  String get key => switch (this) {
    MoodType.great => 'great',
    MoodType.good => 'good',
    MoodType.okay => 'okay',
    MoodType.down => 'down',
    MoodType.difficult => 'difficult',
    MoodType.stressed => 'stressed',
  };

  static MoodType? fromKey(String? key) {
    return switch (key) {
      'great' => MoodType.great,
      'good' => MoodType.good,
      'okay' => MoodType.okay,
      'down' => MoodType.down,
      'difficult' => MoodType.difficult,
      'stressed' => MoodType.stressed,
      _ => null,
    };
  }

  Color get bgColor => switch (this) {
    MoodType.great => const Color(0xFFE7F2E7),
    MoodType.good => const Color(0xFFE3F1FB),
    MoodType.okay => const Color(0xFFF7F0D8),
    MoodType.down => const Color(0xFFF6E6D9),
    MoodType.difficult => const Color(0xFFF4DDE2),
    MoodType.stressed => const Color.fromRGBO(255, 231, 208, 255),
  };
}
