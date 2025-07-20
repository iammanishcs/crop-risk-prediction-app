// In lib/screens/ForgetPass.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  _ForgetPasswordScreenState createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  // --- Controllers, Form Key, and State Variable ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  // --- Firebase Password Reset Function ---
  Future<void> sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent!'), backgroundColor: Colors.green),
        );
        // Pop back to the login screen after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) Navigator.of(context).pop();
        });
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'An error occurred'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Email Validation ---
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Please enter your email';
    final emailPattern = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailPattern.hasMatch(value)) return 'Please enter a valid email address';
    return null;
  }

  // --- Helper for input decoration ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.tealAccent),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
    );
  }

  // --- Futuristic UI Build Method ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212), // Dark background
      appBar: AppBar( // Adding an AppBar for a cleaner back navigation
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.lock_reset, color: Colors.tealAccent, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Reset Password",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Enter your registered email to receive a reset link.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: validateEmail,
                ),
                const SizedBox(height: 30),

                // Send Reset Email Button
                InkWell(
                  onTap: _isLoading ? null : sendPasswordResetEmail,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(colors: [Colors.teal, Colors.cyan], begin: Alignment.topLeft, end: Alignment.bottomRight),
                      boxShadow: [BoxShadow(color: Colors.cyan.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4))],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text("SEND RESET LINK", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}