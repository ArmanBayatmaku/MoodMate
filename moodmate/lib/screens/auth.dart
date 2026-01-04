import 'package:flutter/material.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({
    super.key,
    required this.isLogin,
  });

  final bool isLogin;

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  bool _isSubmitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final ok = _formKey.currentState?.validate() ?? false;
    if (!ok) return;

    FocusScope.of(context).unfocus();

    setState(() => _isSubmitting = true);
    try {
      // TODO: Call your auth logic here
      // e.g. await AuthService.signIn(_emailCtrl.text, _passwordCtrl.text);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF6F1E9);
    const primaryBlue = Color(0xFF7F9BB8);
    const textBlue = Color(0xFF6F8FB0);
    const borderBlue = Color(0xFF8FB0D6);
    const divider = Color(0xFFD9D0C6);

    // Keyboard height (0 when closed)
    final keyboard = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: bg,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboard = MediaQuery.of(context).viewInsets.bottom;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(bottom: keyboard),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: Stack(
                          children: [
                            // Back button
                            Positioned(
                              top: 8,
                              left: 8,
                              child: IconButton(
                                onPressed: () => Navigator.of(context).pop(),
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: textBlue,
                                ),
                              ),
                            ),

                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
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
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                    ),
                                  ),

                                  const SizedBox(height: 22),

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

                                  // Card with Form
                                  Card(
                                    elevation: 0,
                                    color: Colors.white.withOpacity(0.96),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      side: const BorderSide(
                                        color: divider,
                                        width: 1,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        16,
                                        16,
                                        16,
                                        14,
                                      ),
                                      child: Form(
                                        key: _formKey,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            Text(
                                              widget.isLogin
                                                  ? "Sign in with Email"
                                                  : "Sign up with Email",
                                              style: TextStyle(
                                                color: textBlue,
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14.5,
                                              ),
                                            ),
                                            const SizedBox(height: 12),

                                            TextFormField(
                                              controller: _emailCtrl,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              textInputAction:
                                                  TextInputAction.next,
                                              decoration: InputDecoration(
                                                labelText: "Email",
                                                labelStyle: TextStyle(
                                                  color: textBlue,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: borderBlue,
                                                            width: 1.2,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: primaryBlue,
                                                            width: 1.6,
                                                          ),
                                                    ),
                                              ),
                                              validator: (v) {
                                                final s = (v ?? "").trim();
                                                if (s.isEmpty)
                                                  return "Enter email";
                                                if (!s.contains('@')) {
                                                  return "Enter a valid email";
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 12),

                                            TextFormField(
                                              controller: _passwordCtrl,
                                              obscureText: _obscure,
                                              textInputAction:
                                                  TextInputAction.done,
                                              onFieldSubmitted: (_) =>
                                                  _submit(),
                                              decoration: InputDecoration(
                                                labelText: "Password",
                                                labelStyle: TextStyle(
                                                  color: textBlue,
                                                ),
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: borderBlue,
                                                            width: 1.2,
                                                          ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            14,
                                                          ),
                                                      borderSide:
                                                          const BorderSide(
                                                            color: primaryBlue,
                                                            width: 1.6,
                                                          ),
                                                    ),
                                                suffixIcon: IconButton(
                                                  onPressed: () => setState(
                                                    () => _obscure = !_obscure,
                                                  ),
                                                  icon: Icon(
                                                    _obscure
                                                        ? Icons
                                                              .visibility_off_rounded
                                                        : Icons
                                                              .visibility_rounded,
                                                    color: textBlue,
                                                  ),
                                                ),
                                              ),
                                              validator: (v) {
                                                final s = (v ?? "");
                                                if (s.isEmpty) {
                                                  return "Enter password";
                                                }
                                                if (s.length < 6) {
                                                  return "Min 6 characters";
                                                }
                                                return null;
                                              },
                                            ),

                                            const SizedBox(height: 14),

                                            SizedBox(
                                              height: 52,
                                              child: ElevatedButton(
                                                onPressed: _isSubmitting
                                                    ? null
                                                    : _submit,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: primaryBlue,
                                                  foregroundColor: Colors.white,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          16,
                                                        ),
                                                  ),
                                                  textStyle: const TextStyle(
                                                    fontSize: 14.5,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                child: _isSubmitting
                                                    ? const SizedBox(
                                                        height: 18,
                                                        width: 18,
                                                        child:
                                                            CircularProgressIndicator(
                                                              strokeWidth: 2,
                                                            ),
                                                      )
                                                    : Text(
                                                        widget.isLogin
                                                            ? "Continue"
                                                            : "Create account",
                                                      ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        widget.isLogin
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
                                            //widget.isLogin = !widget.isLogin;
                                          });
                                        }, // keep empty
                                        child: Text(
                                          widget.isLogin
                                              ? 'Create account'
                                              : 'Log in',
                                          style: TextStyle(
                                            color: textBlue,
                                            fontSize: 12.5,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: textBlue,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const Spacer(flex: 2),
                                  const SizedBox(height: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
