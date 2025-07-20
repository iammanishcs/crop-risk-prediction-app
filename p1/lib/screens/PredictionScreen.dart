// In lib/screens/PredictionScreen.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  // --- 1. CONTROLLERS AND STATE VARIABLES ---
  final _nController = TextEditingController();
  final _pController = TextEditingController();
  final _kController = TextEditingController();
  final _tempController = TextEditingController();
  final _humidityController = TextEditingController();
  final _phController = TextEditingController();
  final _rainfallController = TextEditingController();

  final List<String> _cropTypes = [
    'rice', 'maize', 'pulses', 'millets', 'sugarcane', 'mungbean',
    'blackgram', 'lentil', 'wheat', 'banana', 'mango', 'grapes', 'cotton'
  ];
  String? _selectedCrop;

  String _predictionResult = "Awaiting Input";
  String _lastPredictionText = "No previous prediction found.";
  bool _isLoading = false;
  final _currentUser = FirebaseAuth.instance.currentUser;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadLastPrediction();
  }

  // --- 2. LOFGIC UNCTIONS ---

  Future<void> _loadLastPrediction() async {
    if (_currentUser == null) return;
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).get();
    if (mounted && userDoc.exists && userDoc.data()!.containsKey('last_prediction')) {
      setState(() {
        _lastPredictionText = "Last Prediction: ${userDoc.data()!['last_prediction']}";
      });
    }
  }

  Future<void> makePrediction() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    // !!! IMPORTANT: REPLACE WITH YOUR COMPUTER'S IP ADDRESS !!!
    final String apiUrl = 'http://192.168.1.7:5000/predict';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({
          'N': _nController.text, 'P': _pController.text, 'K': _kController.text,
          'temperature': _tempController.text, 'humidity': _humidityController.text,
          'ph': _phController.text, 'rainfall': _rainfallController.text,
          'label': _selectedCrop!.toLowerCase(),
        }),
      );

      if (mounted && response.statusCode == 200) {
        final result = jsonDecode(response.body)['risk_level'];
        setState(() => _predictionResult = result);
        if (_currentUser != null) {
          await FirebaseFirestore.instance.collection('users').doc(_currentUser!.uid).update({'last_prediction': result});
        }
      } else {
        setState(() => _predictionResult = "Server Error");
      }
    } catch (e) {
      setState(() => _predictionResult = "Connection Error");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper function to determine the color based on risk
  Color _getRiskColor(String risk) {
    switch (risk.toLowerCase()) {
      case 'high':
        return Colors.redAccent;
      case 'medium':
        return Colors.orangeAccent;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  // Helper for input decoration
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

  // --- 3. FUTURISTIC UI BUILD METHOD ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff121212), // Dark background
      appBar: AppBar(
        title: const Text('Crop Risk Analyzer'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Result Display Card ---
              Card(
                color: _getRiskColor(_predictionResult),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text('PREDICTED RISK LEVEL', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        _predictionResult,
                        style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(height: 8),
                      Text(_lastPredictionText, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // --- Input Section ---
              const Text('Enter Crop and Environmental Data', style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedCrop,
                hint: const Text('Select Crop', style: TextStyle(color: Colors.white70)),
                decoration: _inputDecoration('Crop Type', Icons.grass),
                dropdownColor: const Color(0xff2a2a2a),
                items: _cropTypes.map((String crop) {
                  return DropdownMenuItem<String>(value: crop, child: Text(crop, style: const TextStyle(color: Colors.white)));
                }).toList(),
                onChanged: (newValue) => setState(() => _selectedCrop = newValue),
                validator: (value) => value == null ? 'Please select a crop' : null,
              ),
              const SizedBox(height: 12),

              // Using a GridView for a more compact layout
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 2.5,
                children: [
                  TextFormField(controller: _nController, decoration: _inputDecoration('Nitrogen (N)', Icons.eco), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _pController, decoration: _inputDecoration('Phosphorous (P)', Icons.eco_outlined), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _kController, decoration: _inputDecoration('Potassium (K)', Icons.eco), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _tempController, decoration: _inputDecoration('Temp (°C)', Icons.thermostat), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _humidityController, decoration: _inputDecoration('Humidity (%)', Icons.water_drop), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                  TextFormField(controller: _phController, decoration: _inputDecoration('pH Value', Icons.science), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _rainfallController, decoration: _inputDecoration('Rainfall (mm)', Icons.cloudy_snowing), keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), validator: (v) => v!.isEmpty ? 'Required' : null),

              const SizedBox(height: 24),

              // Calculate Button with Gradient
              InkWell(
                onTap: _isLoading ? null : makePrediction,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      colors: [Colors.teal, Colors.greenAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white))
                        : const Text('ANALYZE RISK', style: TextStyle(fontSize: 18, color: Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}