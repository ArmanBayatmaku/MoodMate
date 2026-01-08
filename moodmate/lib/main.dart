import 'package:flutter/material.dart';
import 'package:moodmate/screens/auth/auth_method.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:moodmate/screens/home/home.dart';
import 'package:moodmate/screens/tabs.dart';
import 'firebase_options.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:moodmate/screens/splash.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:provider/provider.dart';
import 'package:moodmate/controllers/theme_controller.dart';
import 'package:moodmate/models/colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final controller = await ThemeController.load();
  runApp(
    ChangeNotifierProvider.value(
      value: controller,
      child: const App(),
    ),
  );
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.watch<ThemeController>().colors;
    return MaterialApp(
      title: 'MoodMate',
      theme: ThemeData(
        scaffoldBackgroundColor: colors.bg,
        colorScheme: ColorScheme.fromSeed(
          seedColor: colors.accentBlue,
          brightness: Brightness.light,
        ),
        dividerColor: colors.divider,
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: colors.textDark,
          displayColor: colors.textDark,
        ),
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }

          if (snapshot.hasData) {
            return const TabsScreen();
          }

          return const AuthMethodScreen();
        },
      ),
    );
  }
}
