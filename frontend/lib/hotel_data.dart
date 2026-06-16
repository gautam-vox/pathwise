import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'taxi_data.dart';
import 'users_page.dart';

class hotelBookingsPage extends StatefulWidget {
  const hotelBookingsPage({super.key});

  @override
  _hotelBookingsPageState createState() => _hotelBookingsPageState();
}

class _hotelBookingsPageState extends State<hotelBookingsPage> {
  List<dynamic> _hotelBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchhotelBookings();
  }

  // Fetch hotel Bookings from the backend
  Future<void> _fetchhotelBookings() async {
    final response = await http
        .get(Uri.parse('http://${globals.ipAddress}:8000/get_all_hotel_bookings'));

    if (response.statusCode == 200) {
      setState(() {
        _hotelBookings = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch hotel bookings')),
      );
    }
  }

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
                'Hello, Admin!',
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
              title: const Text('Manage Users'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const UsersPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.hotel),
              title: const Text('Hotel Booking'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const hotelBookingsPage()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text('Taxi Booking'),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const TaxiBookingsPage()),
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
      body: _hotelBookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _hotelBookings.map((booking) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text('Booking ID: ${booking['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('POI: ${booking['hotel_poi']}'),
                        Text('Check-in: ${booking['checkin_date']}'),
                        Text('Check-out: ${booking['checkout_date']}'),
                        Text('Fare: ${booking['fare']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
