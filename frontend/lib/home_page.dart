import 'package:pathwise/hotel_booking.dart';
import 'package:pathwise/edit_profile.dart';
import 'package:pathwise/map_view.dart';
import 'package:pathwise/taxi_booking.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'schedule.dart';
import 'user_history.dart';

class HomeActivity extends StatefulWidget {
  const HomeActivity({super.key});

  @override
  State<HomeActivity> createState() => _HomeActivityState();
}

class _HomeActivityState extends State<HomeActivity> {
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  // Load the username from SharedPreferences
  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username') ?? 'Guest';
    });
  }

  // Logout function
  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username'); // Remove username from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginActivity()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true, // Center the title
        title: const Text(
          'Pathwise',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(
              Icons.menu,
              color: Colors.white, // Set the menu icon color to white
            ),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black,
              ),
              child: Text(
                'Hello, $_username!',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profile'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const EditProfile()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel),
              title: const Text('Hotel Booking'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => hotelBookingPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text('Taxi Booking'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => TaxiBookingPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MapScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('History'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        UserBookingPage(), // Pass the username dynamically
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.scale),
              title: const Text('Trip Schedule'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        BookingSchedulePage(), // Pass the username dynamically
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/chicago.jpg'), // Add your image to assets
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Centered Card
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.8, // 80% of screen width
              child: Opacity(
                opacity: 0.9, // Reduce opacity for the card
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 5,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'About.',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'The mobile application is a user-friendly platform designed for Pathanamthitta, offering interactive maps, essential service directories, and seamless booking for transportation and hotels. It includes offline map access and a streamlined interface, ensuring convenience for users in navigating points of interest and managing travel needs efficiently.',
                          style: TextStyle(fontSize: 16),
                          textAlign: TextAlign.justify,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
