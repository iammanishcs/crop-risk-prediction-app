import 'package:flutter/material.dart';
import 'LoginScreen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Upper Half
          Expanded(
            flex: 1, // Ensures equal height split
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40), // Rounded bottom corners
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "🌿 THE NEW ERA OF",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "AGRICULTURE",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Sustainable farming solutions for a better tomorrow.",
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.eco, color: Colors.green),
                      Text(
                        " Growth: 12 cm",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 20),
                      Icon(Icons.water_drop, color: Colors.black),
                      Text(
                        " Moisture: 75%",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Lower Half
          Expanded(
            flex: 1, // Ensures equal height split
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(40), // Smooth top transition
                topRight: Radius.circular(40),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.asset(
                      "assets/images/Background.jpg",
                      fit: BoxFit.cover, // Ensure full coverage
                    ),
                  ),
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.46), // Adjust opacity
                    ),
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: ElevatedButton(
                        // Inside your "Get Started" ElevatedButton on the LandingScreen
                          onPressed: () {
                            // We use pushReplacement so the user can't press the back button
                            // to return to this landing screen.
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => LoginScreen()),
                            );
                          },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.brown,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        ),
                        child: const Text(
                          "Get Started",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
