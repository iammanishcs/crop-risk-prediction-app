// In lib/screens/LoginScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignupScreen.dart'; // Import for navigation
import 'ForgetPass.dart'; // Import for navigation
import 'PredictionScreen.dart'; // Import for navigation

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Controllers and Form Key ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false; // To manage loading state

  // --- Firebase Sign-In Function ---
  Future<void> signInUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PredictionScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? "An error occurred"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(Icons.shield_moon_outlined, color: Colors.tealAccent, size: 80),
                const SizedBox(height: 20),
                const Text(
                    "Welcome Back",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)
                ),
                const Text(
                    "Sign in to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.white70)
                ),
                const SizedBox(height: 40),

                // Email Field
                TextFormField(
                  controller: _emailController,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => value!.isEmpty ? "Please enter your email" : null,
                ),
                const SizedBox(height: 15),

                // Password Field
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: _inputDecoration("Password", Icons.lock_outline),
                  style: const TextStyle(color: Colors.white),
                  validator: (value) => value!.isEmpty ? "Please enter your password" : null,
                ),
                const SizedBox(height: 10),

                // Forget Password Link
                Align(
                  alignment: Alignment.centerRight,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ForgetPasswordScreen()),
                      );
                    },
                    child: const Text(
                      "Forgot Password?",
                      style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Login Button
                InkWell(
                  onTap: _isLoading ? null : signInUser,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        colors: [Colors.teal, Colors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(color: Colors.cyan.withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: _isLoading
                          ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                          : const Text("LOGIN", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Don't have an account? Sign Up
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Don't have an account? ", style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      },
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}