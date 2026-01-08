import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:moodmate/screens/auth/auth.dart';

import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:moodmate/screens/tabs.dart';

class AuthMethodScreen extends StatefulWidget {
  const AuthMethodScreen({super.key});

  @override
  State<AuthMethodScreen> createState() => _AuthMethodScreenState();
}

class _AuthMethodScreenState extends State<AuthMethodScreen> {
  var _isLogin = true;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1E9);
    const primaryBlue = Color(0xFF7F9BB8);
    const textBlue = Color(0xFF6F8FB0);
    const borderBlue = Color(0xFF8FB0D6);
    const divider = Color(0xFFD9D0C6);

    Future<void> _signInWithGoogle() async {
      try {
        // 1. Trigger the Google Authentication flow
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

        // If the user cancels the login, googleUser is null
        if (googleUser == null) return;

        // 2. Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        // 3. Create a new credential
        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // 4. Sign in to Firebase with the new credential
        await FirebaseAuth.instance.signInWithCredential(credential);

        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const TabsScreen()),
          (route) => false,
        );

        // Optional: Navigate to your next screen if needed
        // Navigator.of(context).pushReplacementNamed('/chat');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign in failed: $e')),
        );
      }
    }

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo
                  Container(
                    margin: const EdgeInsets.only(
                      top: 30,
                      bottom: 20,
                      left: 20,
                      right: 20,
                    ),
                    width: 150,
                    child: Image.asset('assets/images/logo.png'),
                  ),

                  const SizedBox(height: 22),

                  //Text under logo
                  Text(
                    "Mood Mate",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textBlue,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "Your daily check-in made simple and caring",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textBlue.withOpacity(0.85),
                    ),
                  ),

                  const SizedBox(height: 120),

                  // Sign in with Email
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (ctx) => AuthScreen(
                              isLogin: _isLogin,
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.mail_outline_rounded, size: 20),
                      label: Text(
                        _isLogin
                            ? ' Sign in with Email'
                            : ' Sign up with Email',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBlue,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  /*// Continue with Google. TODO!!!!!
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: Icon(
                        Icons.g_mobiledata_rounded,
                        size: 26,
                        color: textBlue,
                      ),
                      label: const Text("Continue with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.96),
                        foregroundColor: textBlue,
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.2,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),*/
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      // Hook up the function here
                      onPressed: _signInWithGoogle,
                      icon: const Icon(
                        Icons.g_mobiledata_rounded,
                        size: 26,
                        color:
                            textBlue, // Ensure 'textBlue' is defined in your class
                      ),
                      label: const Text("Continue with Google"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.96),
                        foregroundColor: textBlue,
                        elevation: 2,
                        shadowColor: Colors.black12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 1.2,
                          ),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 156),
                  /*
                  // Divider line"
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(thickness: 1, color: divider),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          "or",
                          style: TextStyle(
                            color: textBlue.withOpacity(0.7),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(thickness: 1, color: divider),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Continue as Guest. TODO !!!!!!!
                  SizedBox(
                    height: 54,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textBlue,
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(color: borderBlue, width: 1.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text("Continue as Guest"),
                    ),
                  ),

                  const Spacer(flex: 2),*/

                  // Swap to sign up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isLogin
                            ? 'Not on our app yet? '
                            : 'Already have an account?',
                        style: TextStyle(
                          color: textBlue.withOpacity(0.8),
                          fontSize: 12.5,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            _isLogin = !_isLogin;
                          });
                        },
                        child: Text(
                          _isLogin ? 'Create account' : 'Log in',
                          style: TextStyle(
                            color: textBlue,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: textBlue,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
