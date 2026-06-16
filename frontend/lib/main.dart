import 'package:pathwise/admin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:async';
import 'taxi_admin_page.dart';
import 'hotel_admin.dart';
import 'signup_activity.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart'; // Your home page after successful login

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Disable the debug banner
      title: 'Pathwise',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),

      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: [
        Locale('en'),
        Locale('hi'),
      ],

      home: const SplashScreen(), // Set SplashScreen as the initial screen
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginActivity()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.explore, // Compass icon
              size: 100,
              color: Colors.white,
            ),
            SizedBox(height: 20),
            Text(
              'P a t h w i s e',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginActivity extends StatefulWidget {
  const LoginActivity({super.key});

  @override
  State<LoginActivity> createState() => _LoginActivityState();
}

class _LoginActivityState extends State<LoginActivity> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    // Get username and password
    final username = _usernameController.text;
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter both username and password';
      });
      return;
    }

    // Check for Taxi Admin credentials
    if (username == 'Taxi' && password == 'management') {
      setState(() {
        _isLoading = false;
      });
      // Navigate to TaxiAdminPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const TaxiAdminPage()),
      );
      return;
    }

    // Check for hotel Admin credentials
    if (username == 'hotel' && password == 'management') {
      setState(() {
        _isLoading = false;
      });
      // Navigate to hotelAdminPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const hotelAdminPage()),
      );
      return;
    }

    if (username == 'Admin' && password == 'admin123') {
      setState(() {
        _isLoading = false;
      });
      // Navigate to hotelAdminPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminPage()),
      );
      return;
    }
    // Prepare the request body
    final Map<String, String> requestBody = {
      'username': username,
      'password': password,
    };

    // Make the HTTP POST request to the login API
    final response = await http.post(
      Uri.parse('http://${globals.ipAddress}:8000/login'), // Your Flask API endpoint
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestBody),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode == 200) {
      // If login is successful, save username to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('username', username);

      // Navigate to HomeActivity
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeActivity()),
      );
    } else {
      // If login fails, show error message
      final responseData = json.decode(response.body);
      setState(() {
        _errorMessage = responseData['message'] ?? 'Unknown error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black, // Black background
        title: const Center(
          child: Text(
            'Pathwise',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/moonsky.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Transparent overlay for readability
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          Center(
            child: Card(
              elevation: 5,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Login',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        minimumSize:
                            const Size(150, 50), // Minimal width and height
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        backgroundColor: const Color.fromARGB(255, 0, 255, 225),
                        shadowColor: const Color.fromARGB(255, 35, 182, 199),
                        elevation: 5,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                              color: Colors.cyan,
                            )
                          : const Text(
                              'Login',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                    const SizedBox(height: 10),
                    if (_errorMessage.isNotEmpty)
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const SignupActivity()),
                        );
                      },
                      child: const Text(
                        "Don't have an account? Register",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
