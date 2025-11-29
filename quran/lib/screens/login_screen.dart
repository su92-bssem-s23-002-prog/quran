import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/google_auth_service.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    // Validate inputs
    if (_emailController.text.trim().isEmpty) {
      _showError('Please enter your email');
      return;
    }
    if (!_isValidEmail(_emailController.text.trim())) {
      _showError('Please enter a valid email address');
      return;
    }
    if (_passwordController.text.isEmpty) {
      _showError('Please enter your password');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      // Auth successful via email/password

      // Login successful
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'user-not-found') {
        message = 'No account found with this email';
      } else if (e.code == 'wrong-password') {
        message = 'Incorrect password';
      } else if (e.code == 'invalid-email') {
        message = 'Invalid email address';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password';
      }
      _showError(message);
    } catch (e) {
      _showError('Failed to login. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final user = await GoogleAuthService().signIn();
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return; // cancelled
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('Google sign-in error: code=${e.code} message=${e.message}');
      String message = switch (e.code) {
        'account-exists-with-different-credential' =>
          'An account already exists with this email',
        'network-request-failed' => 'Network error. Check your connection.',
        'developer_error' => 'Configuration error (SHA-1 / google-services).',
        _ => 'Google sign-in failed (${e.code})',
      };
      _showError(message);
    } catch (e) {
      _showError('Failed to sign in with Google');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithFacebook() async {
    setState(() => _isLoading = true);

    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final OAuthCredential credential = FacebookAuthProvider.credential(
          result.accessToken!.tokenString,
        );
        await FirebaseAuth.instance.signInWithCredential(credential);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else if (result.status == LoginStatus.cancelled) {
        setState(() => _isLoading = false);
      } else {
        _showError('Facebook sign-in failed');
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showError('Failed to sign in with Facebook');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController();

    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          'Reset Password',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter your email address and we\'ll send you a link to reset your password.',
              style: TextStyle(color: Colors.black54, fontSize: 14),
            ),
            SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Color(0xFF1db854)),
                prefixIcon: Icon(Icons.email, color: Color(0xFF1db854)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF1db854), width: 2),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = emailController.text.trim();

              if (email.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter your email'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              if (!_isValidEmail(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid email'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(
                  email: email,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Password reset email sent! Check your inbox.',
                    ),
                    backgroundColor: Color(0xFF1db854),
                  ),
                );
              } on FirebaseAuthException catch (e) {
                String message = 'Failed to send reset email';
                if (e.code == 'user-not-found') {
                  message = 'No account found with this email';
                } else if (e.code == 'invalid-email') {
                  message = 'Invalid email address';
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(message), backgroundColor: Colors.red),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF1db854),
              foregroundColor: Colors.white,
            ),
            child: Text('Send Reset Link'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 30),
                // Logo
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFe0f2f1),
                  ),
                  child: ClipOval(
                    child: Image.asset('assets/logo.png', fit: BoxFit.cover),
                  ),
                ),
                SizedBox(height: 40),
                // Title
                Text(
                  'Welcome Back',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1a1a1a),
                  ),
                ),
                SizedBox(height: 40),
                // Email Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Color(0xFF1a1a1a)),
                      decoration: InputDecoration(
                        hintText: 'Enter your email',
                        hintStyle: TextStyle(color: Color(0xFFb0b0b0)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFe0e0e0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFFe0e0e0),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFF1db854),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFf5f5f5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                // Password Field
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Password',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: TextStyle(color: Color(0xFF1a1a1a)),
                      decoration: InputDecoration(
                        hintText: 'Enter your password',
                        hintStyle: TextStyle(color: Color(0xFFb0b0b0)),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Color(0xFFb0b0b0),
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Color(0xFFe0e0e0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFFe0e0e0),
                            width: 1.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Color(0xFF1db854),
                            width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: Color(0xFFf5f5f5),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),
                // Forgot Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: _showForgotPasswordDialog,
                    child: Text(
                      'Forgot Password?',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1db854),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 32),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF1db854),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: Color(
                        0xFF1db854,
                      ).withOpacity(0.5),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 28),
                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(color: Color(0xFFe0e0e0), thickness: 1),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Color(0xFFb0b0b0),
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(color: Color(0xFFe0e0e0), thickness: 1),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Google Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithGoogle,
                    icon: Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: Color(0xFF1a1a1a),
                    ),
                    label: Text(
                      'Continue with Google',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Color(0xFFe0e0e0), width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                // Facebook Continue Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _isLoading ? null : _signInWithFacebook,
                    icon: Icon(
                      Icons.facebook,
                      size: 24,
                      color: Color(0xFF1a1a1a),
                    ),
                    label: Text(
                      'Continue with Facebook',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1a1a1a),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: BorderSide(color: Color(0xFFe0e0e0), width: 1.5),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                // Sign Up Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(fontSize: 14, color: Color(0xFF7a7a7a)),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        'Sign Up',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1db854),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
