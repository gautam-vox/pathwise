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
import 'schedule.dart';
import 'taxi_booking.dart';

class hotelBookingPage extends StatefulWidget {
  @override
  _hotelBookingPageState createState() => _hotelBookingPageState();
}

class _hotelBookingPageState extends State<hotelBookingPage> {
  final TextEditingController _startPointController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  String? selectedhotel;
  String? username;
  DateTime? selectedCheckInDate;
  DateTime? selectedCheckOutDate;
  int? numberOfPeople;

  // Define the hotel options which will be updated dynamically
  Map<String, List<String>> hotelOptions = {
    'Resorts': [],
    'Budget Stays': [],
    'Homestays': [],
  };

  String hotelPoi =
      ''; // Store the hotel type ('Resorts', 'Budget Stays', 'Homestays')

  Future<void> getUsernameFromPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });
    if (username != null) {
      await fetchhotelOptions(username!);
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

  Future<void> fetchhotelOptions(String username) async {
    final url =
        Uri.parse('http://${globals.ipAddress}:8000/get_profile?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          hotelPoi = data['user']['hotel_poi']; // Get hotel_poi from response
        });

        // Set the available hotel options dynamically based on the response
        setState(() {
          // Clear all existing options first to ensure fresh data
          hotelOptions['Resorts'] = [];
          hotelOptions['Budget Stays'] = [];
          hotelOptions['Homestays'] = [];

          if (hotelPoi == 'Resorts') {
            hotelOptions['Resorts'] = [
              'Mount Tales Vagamon',
              'Vagamon Lake Resort'
            ];
          } else if (hotelPoi == 'Budget Stays') {
            hotelOptions['Budget Stays'] = [
              'Hotel Hills Park',
              'Pathanamthitta Budget Inn'
            ];
          } else if (hotelPoi == 'Homestays') {
            hotelOptions['Homestays'] = [
              'Green Homestay',
              'Vasthuhome Homestay'
            ];
          }

          Fluttertoast.showToast(
            msg: 'Fetched hotel Options for $username is $hotelPoi ',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.green,
            textColor: Colors.white,
          );
        });
      } else {
        Fluttertoast.showToast(
          msg: 'Failed to fetch hotel options: Server error',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Error fetching hotel options: $e',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    }
  }

  Future<void> saveBooking() async {
    if (selectedhotel == null ||
        selectedCheckInDate == null ||
        selectedCheckOutDate == null ||
        numberOfPeople == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final url = Uri.parse('http://${globals.ipAddress}:8000/save_hotel_booking');
    final payload = {
      'username': username,
      'hotel_poi': selectedhotel,
      'checkin_date': selectedCheckInDate!.toIso8601String(),
      'checkout_date': selectedCheckOutDate!.toIso8601String(),
      'number_of_people': numberOfPeople,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hotel booking saved successfully')),
        );
      } else {
        throw Exception('Failed to save booking');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectCheckInDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedCheckInDate) {
      setState(() {
        selectedCheckInDate = pickedDate;
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != selectedCheckOutDate) {
      setState(() {
        selectedCheckOutDate = pickedDate;
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
    // Format the selected check-in and check-out dates if they are not null
    String formattedCheckInDate = selectedCheckInDate == null
        ? 'Select Check-in Date'
        : DateFormat('yyyy-MM-dd').format(selectedCheckInDate!);

    String formattedCheckOutDate = selectedCheckOutDate == null
        ? 'Select Check-out Date'
        : DateFormat('yyyy-MM-dd').format(selectedCheckOutDate!);

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
      body: username == null
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
                            'Hotel Booking',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 16),
                          // Display a Dropdown button for hotel type
                          DropdownButtonFormField<String>(
                            value: selectedhotel,
                            items: hotelOptions[hotelPoi]!
                                .map((hotel) => DropdownMenuItem(
                                      value: hotel,
                                      child: Text(hotel),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => selectedhotel = value),
                            decoration: InputDecoration(
                              labelText: 'Hotel Type',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          SizedBox(height: 16),
                          // Display a date picker for Check-in and Check-out dates
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: _selectCheckInDate,
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: formattedCheckInDate),
                                      decoration: InputDecoration(
                                        labelText: 'Check-in Date',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: InkWell(
                                  onTap: _selectCheckOutDate,
                                  child: AbsorbPointer(
                                    child: TextField(
                                      controller: TextEditingController(
                                          text: formattedCheckOutDate),
                                      decoration: InputDecoration(
                                        labelText: 'Check-out Date',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          // Input for number of people
                          TextField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Number of People',
                              border: OutlineInputBorder(),
                            ),
                            onChanged: (value) {
                              setState(() {
                                numberOfPeople = int.tryParse(value);
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: saveBooking,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green, // Text color
                              textStyle: TextStyle(
                                fontWeight:
                                    FontWeight.bold, // Make the text bold
                              ),
                            ),
                            child: const Text('Save Booking'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: Card(
                    color: Colors.blueAccent,
                    elevation: 8,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Fare Rate',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                              height:
                                  8), // Adds space between title and the rates

                          // Resort Fare Range
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              const Text(
                                'Resort: RS 5000 - RS 7000',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  8), // Adds space between Resort and Budget Stays

                          // Budget Stays Fare Range
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              const Text(
                                'Budget Stays: RS 1000 - RS 3000',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                              height:
                                  8), // Adds space between Budget Stays and Homestays

                          // Homestays Fare Range
                          Row(
                            children: [
                              Icon(
                                Icons.attach_money,
                                color: Colors.white,
                              ),
                              SizedBox(width: 8),
                              const Text(
                                'Homestays: RS 3000 - RS 5000',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
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
