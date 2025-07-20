// In lib/screens/auth_gate.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'LoginScreen.dart'; // Correctly import LoginScreen
import 'PredictionScreen.dart'; // Correctly import PredictionScreen

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( // It's good practice to wrap it in a Scaffold
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // If the stream is still waiting, show a loading indicator
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // User is not logged in
          if (!snapshot.hasData) {
            return const LoginScreen();
          }

          // User is logged in
          return const PredictionScreen();
        },
      ),
    );
  }
}