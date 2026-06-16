import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'hotel_data.dart';
import 'main.dart';
import 'users_page.dart';

class TaxiBookingsPage extends StatefulWidget {
  const TaxiBookingsPage({super.key});

  @override
  _TaxiBookingsPageState createState() => _TaxiBookingsPageState();
}

class _TaxiBookingsPageState extends State<TaxiBookingsPage> {
  List<dynamic> _taxiBookings = [];

  @override
  void initState() {
    super.initState();
    _fetchTaxiBookings();
  }

  // Fetch Taxi Bookings from the backend
  Future<void> _fetchTaxiBookings() async {
    final response = await http
        .get(Uri.parse('http://${globals.ipAddress}:8000/get_all_taxi_bookings'));

    if (response.statusCode == 200) {
      setState(() {
        _taxiBookings = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch taxi bookings')),
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
      body: _taxiBookings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: _taxiBookings.map((booking) {
                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text('Booking ID: ${booking['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Start Point: ${booking['start_point']}'),
                        Text('Destination: ${booking['destination_point']}'),
                        Text('Date: ${booking['date']}'),
                        Text('Charge: ${booking['charge']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
