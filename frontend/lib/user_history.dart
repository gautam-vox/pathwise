import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'hotel_booking.dart';
import 'edit_profile.dart';
import 'main.dart';
import 'map_view.dart';
import 'schedule.dart';
import 'taxi_booking.dart'; // Import SharedPreferences

class UserBookingPage extends StatefulWidget {
  const UserBookingPage({super.key});

  @override
  _UserBookingPageState createState() => _UserBookingPageState();
}

class _UserBookingPageState extends State<UserBookingPage> {
  String _username = ''; // Username will be fetched from SharedPreferences
  List<dynamic> _userTaxiBookings = [];
  List<dynamic> _userhotelBookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUsername();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username'); // Remove username from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginActivity()),
    );
  }

  // Fetch username from SharedPreferences
  Future<void> _getUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username'); // Retrieve the saved username
    if (username != null) {
      setState(() {
        _username = username;
      });
      _fetchUserTaxiBookings();
      _fetchUserhotelBookings();
    } else {
      // Handle the case where the username is not found
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No username found')),
      );
    }
  }

  Future<void> _fetchUserTaxiBookings() async {
    final response = await http.get(Uri.parse(
        'http://${globals.ipAddress}:8000/get_taxi_user?username=$_username'));

    if (response.statusCode == 200) {
      setState(() {
        _userTaxiBookings = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch taxi bookings')),
      );
    }
  }

  Future<void> _fetchUserhotelBookings() async {
    final response = await http.get(Uri.parse(
        'http://${globals.ipAddress}:8000/get_hotel_user?username=$_username'));

    if (response.statusCode == 200) {
      setState(() {
        _userhotelBookings = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch hotel bookings')),
      );
    }
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: ListView(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.grey[200],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Taxi Bookings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._userTaxiBookings.map((booking) {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text('Booking ID: ${booking['id']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        'Start Point: ${booking['start_point']}'),
                                    Text(
                                        'Destination: ${booking['destination_point']}'),
                                    Text(
                                        'Transport: ${booking['preferred_transport']}'),
                                    Text('Date: ${booking['date']}'),
                                    Text('Charge: ${booking['charge']}'),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.grey[200],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hotel Bookings',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ..._userhotelBookings.map((booking) {
                            return Card(
                              elevation: 2,
                              child: ListTile(
                                title: Text('Booking ID: ${booking['id']}'),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('POI: ${booking['hotel_poi']}'),
                                    Text(
                                        'Check-in: ${booking['checkin_date']}'),
                                    Text(
                                        'Check-out: ${booking['checkout_date']}'),
                                    Text(
                                        'People: ${booking['number_of_people']}'),
                                    Text('Fare: ${booking['fare']}'),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
