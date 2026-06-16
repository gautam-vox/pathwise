import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'edit_profile.dart';
import 'home_page.dart';
import 'main.dart';
import 'map_view.dart';
import 'schedule.dart'; // Import the intl package for date formatting

class TaxiBookingPage extends StatefulWidget {
  @override
  _TaxiBookingPageState createState() => _TaxiBookingPageState();
}

class _TaxiBookingPageState extends State<TaxiBookingPage> {
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? selectedTransport;
  String? username;
  String? taxiPoi;
  DateTime? selectedDate;

  Future<void> getUsernameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    if (username != null) {
      await fetchTaxiPoi(username!);
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

  Future<void> fetchTaxiPoi(String username) async {
    final url =
        Uri.parse('http://${globals.ipAddress}:8000/get_profile?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          taxiPoi = data['user']['taxi_poi'];
        });
        Fluttertoast.showToast(
          msg: 'Fetched Taxi POI: $taxiPoi',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch taxi POI: Server error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching taxi POI: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> saveBooking() async {
    if (_startPointController.text.isEmpty ||
        _destinationController.text.isEmpty ||
        selectedTransport == null ||
        selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final url = Uri.parse('http://${globals.ipAddress}:8000/save_taxi_booking');
    final payload = {
      'username': username,
      'start_point': _startPointController.text,
      'destination_point': _destinationController.text,
      'preferred_transport': selectedTransport,
      'date': selectedDate!.toIso8601String(),
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Taxi booking saved successfully')),
        );
      } else {
        throw Exception('Failed to save booking');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getUsernameFromPreferences();
  }

  @override
  Widget build(BuildContext context) {
    // Format the selected date if it is not null
    String formattedDate = selectedDate == null
        ? 'Select Booking Date'
        : DateFormat('yyyy-MM-dd').format(selectedDate!);

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
                'Hello, $username!',
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeActivity()),
                );
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
              onTap: () {},
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
      body: username == null || taxiPoi == null
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                Center(
                  child: Card(
                    elevation: 4,
                    margin: const EdgeInsets.all(16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Taxi Booking',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _startPointController,
                            decoration: InputDecoration(
                              labelText: 'Starting Point',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          TextField(
                            controller: _destinationController,
                            decoration: InputDecoration(
                              labelText: 'Destination Point',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          DropdownButtonFormField<String>(
                            value: selectedTransport,
                            items: [
                              DropdownMenuItem(
                                value: "Car",
                                child: Text(
                                  "Car",
                                  style: TextStyle(
                                    color: taxiPoi == "Car"
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              ),
                              DropdownMenuItem(
                                value: "Bus transport",
                                child: Text(
                                  "Bus transport",
                                  style: TextStyle(
                                    color: taxiPoi == "Bus transport"
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) =>
                                setState(() => selectedTransport = value),
                            decoration: InputDecoration(
                              labelText: 'Preferred Transport',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  'Date: $formattedDate',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: _selectDate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text('Pick Date'),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: saveBooking,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 40,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            child: Text(
                              'Book Taxi',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top:
                      10, // Adjust this value to control how far down the card appears
                  right: 16,
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      width: 220,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fare Rate',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'For car taxis, the charge is between the range of 500 to 1000 within Pathanamthitta.',
                            style: TextStyle(fontSize: 12),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'For bus transport, the charge is between the range from 30 to 200.',
                            style: TextStyle(fontSize: 12),
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
