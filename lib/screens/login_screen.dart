import 'package:flutter/material.dart';
import 'signup_screen.dart';
import 'welcome_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;
  bool _loading = false;

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    // Simulated authentication delay
    await Future.delayed(const Duration(seconds: 1));

    setState(() => _loading = false);

    // Dummy check
    if (_usernameController.text.trim() == "test@example.com" && _passwordController.text == "Test@123") {
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => WelcomeScreen(name: _usernameController.text)));
    } else {
      _showSnack('Incorrect username or password');
    }
  }

  Widget _googleSignInButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFF4285F4)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        icon: Image.asset('assets/google_logo.png', height: 24),
        label: const Text(
          'Google',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        onPressed: () => _showSnack("Google login coming soon"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8FAFD),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 390),
            child: Card(
              color: Colors.white.withOpacity(0.94),
              elevation: 20,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 34),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/login_logo.png', height: 82),
                    const SizedBox(height: 10),
                    const Text(
                      'Sign In',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.3),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Enter valid user name & password to continue',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 25),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _usernameController,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline),
                              hintText: 'User name',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty
                                ? "Please enter your username"
                                : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_showPassword,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.lock_outline),
                              hintText: 'Password',
                              border: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(10))),
                              suffixIcon: IconButton(
                                icon: Icon(_showPassword
                                    ? Icons.visibility
                                    : Icons.visibility_off),
                                onPressed: () => setState(() => _showPassword = !_showPassword),
                              ),
                            ),
                            validator: (val) => val == null || val.length < 6
                                ? "Password must be at least 6 chars"
                                : null,
                          ),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _showSnack("Implement forget password logic!"),
                        child: const Text('Forget password', style: TextStyle(fontSize: 12)),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff3970F6),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(13)),
                          elevation: 2,
                          textStyle:
                              const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                        ),
                        child: _loading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text('Login'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Expanded(child: Divider()),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 9),
                          child: Text(
                            'Or Continue with',
                            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                          ),
                        ),
                        const Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _googleSignInButton(),
                    const SizedBox(height: 18),
                    Center(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SignupScreen()),
                        ),
                        child: const Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                  text: 'Haven\'t any account? ',
                                  style: TextStyle(color: Colors.grey, fontSize: 13)),
                              TextSpan(
                                text: 'Sign up',
                                style: TextStyle(
                                    color: Color(0xff3970F6),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
