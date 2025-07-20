// In lib/screens/SignUpScreen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'LoginScreen.dart';
import 'PredictionScreen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // --- Controllers, Form Key, and State Variables ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _cnicController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _selectedDistrict;
  bool _isLoading = false;

  final List<String> districts = [
    "attock", "bakar", "bahawalnagar", "bwp", "chakwall", "chainiot",
    "d.g.khan", "digikhan", "faisalabad", "gujranwala", "gujrat",
    "hafizabad", "isl", "jehlum", "jhang", "kasur", "khanewal",
    "khushab", "lahore", "layyah", "lodhran", "m.b.din", "m.garh",
    "mianwali", "multan", "muzafargarh", "nankana sahib", "narowall",
    "okara", "pakpatan", "rajanpur", "rawalpindi", "ryk", "sahiwal",
    "sarjodha", "shekupora", "sialkot", "tobataiksingh", "vihari"
  ];

  // --- Firebase SignUp Function ---
  Future<void> signUpAndStoreUser() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      String userId = userCredential.user!.uid;

      await FirebaseFirestore.instance.collection('users').doc(userId).set({
        'uid': userId,
        'email': _emailController.text.trim(),
        'cnic': _cnicController.text.trim(),
        'contact_no': _contactController.text.trim(),
        'district': _selectedDistrict,
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const PredictionScreen()),
              (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}"), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- Validation functions ---
  String? validateCNIC(String? value) { /* Your validation logic here */ return null; }
  String? validateContact(String? value) { /* Your validation logic here */ return null; }
  String? validateEmail(String? value) { /* Your validation logic here */ return null; }

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
                const Icon(Icons.app_registration_rounded, color: Colors.tealAccent, size: 80),
                const SizedBox(height: 20),
                const Text(
                  "Create Account",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const Text(
                  "Get started with your crop analysis",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),
                const SizedBox(height: 30),

                TextFormField(controller: _emailController, decoration: _inputDecoration("Email", Icons.email_outlined), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.emailAddress, validator: validateEmail),
                const SizedBox(height: 15),
                TextFormField(controller: _cnicController, decoration: _inputDecoration("CNIC (e.g., 12345-1234567-1)", Icons.badge_outlined), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.number, validator: validateCNIC),
                const SizedBox(height: 15),
                TextFormField(controller: _contactController, decoration: _inputDecoration("Contact No (e.g., 03xxxxxxxxx)", Icons.phone_outlined), style: const TextStyle(color: Colors.white), keyboardType: TextInputType.phone, validator: validateContact),
                const SizedBox(height: 15),

                DropdownButtonFormField<String>(
                  value: _selectedDistrict,
                  decoration: _inputDecoration("District", Icons.location_city_outlined),
                  dropdownColor: const Color(0xff2a2a2a),
                  items: districts.map((district) => DropdownMenuItem(value: district, child: Text(district, style: const TextStyle(color: Colors.white)))).toList(),
                  onChanged: (value) => setState(() => _selectedDistrict = value),
                  validator: (value) => value == null ? 'Please select a district' : null,
                ),
                const SizedBox(height: 15),

                TextFormField(controller: _passwordController, obscureText: true, decoration: _inputDecoration("Password", Icons.lock_outline), style: const TextStyle(color: Colors.white), validator: (v) => v!.length < 6 ? "Password must be > 6 chars" : null),
                const SizedBox(height: 15),
                TextFormField(controller: _confirmPasswordController, obscureText: true, decoration: _inputDecoration("Confirm Password", Icons.lock_outline_rounded), style: const TextStyle(color: Colors.white), validator: (v) => v != _passwordController.text ? "Passwords do not match" : null),

                const SizedBox(height: 30),

                // Sign Up Button
                InkWell(
                  onTap: _isLoading ? null : signUpAndStoreUser,
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
                          : const Text("SIGN UP", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Already have an account? Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already have an account? ", style: TextStyle(color: Colors.white70)),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                      child: const Text("Login", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.tealAccent)),
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