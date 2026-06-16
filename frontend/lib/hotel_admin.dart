import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart';
import 'globals.dart' as globals;

class hotelAdminPage extends StatefulWidget {
  const hotelAdminPage({super.key});

  @override
  State<hotelAdminPage> createState() => _hotelAdminPageState();
}

class _hotelAdminPageState extends State<hotelAdminPage> {
  List<dynamic> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchhotels();
  }

  Future<void> _fetchhotels() async {
    final response = await http
        .get(Uri.parse('http://${globals.ipAddress}:8000/get_hotel_bookings'));

    if (response.statusCode == 200) {
      setState(() {
        _hotels = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch hotels')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> hotel) {
    final TextEditingController poiController =
        TextEditingController(text: hotel['hotel_poi']);
    final TextEditingController checkinController =
        TextEditingController(text: hotel['checkin_date']);
    final TextEditingController checkoutController =
        TextEditingController(text: hotel['checkout_date']);
    final TextEditingController peopleController =
        TextEditingController(text: hotel['number_of_people'].toString());
    final TextEditingController fareController =
        TextEditingController(text: hotel['fare'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit hotel'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: poiController,
                decoration: const InputDecoration(labelText: 'Hotel POI'),
              ),
              TextField(
                controller: checkinController,
                decoration: const InputDecoration(labelText: 'Check-in Date'),
              ),
              TextField(
                controller: checkoutController,
                decoration: const InputDecoration(labelText: 'Check-out Date'),
              ),
              TextField(
                controller: peopleController,
                decoration:
                    const InputDecoration(labelText: 'Number of People'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: fareController,
                decoration: const InputDecoration(labelText: 'Fare'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final updatedhotel = {
                'id': hotel['id'],
                'hotel_poi': poiController.text,
                'checkin_date': checkinController.text,
                'checkout_date': checkoutController.text,
                'number_of_people': int.tryParse(peopleController.text),
                'fare': double.tryParse(fareController.text),
              };

              final response = await http.post(
                Uri.parse('http://${globals.ipAddress}:8000/update_hotel_booking'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(updatedhotel),
              );

              if (response.statusCode == 200) {
                setState(() {
                  _fetchhotels();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Hotel updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update hotel')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
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
        title: const Text(
          'Pathwise',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Card(
                    color: Colors.grey[200],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Hotel Admin Panel',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minWidth: 800),
                        child: DataTable(
                          columns: const [
                            DataColumn(label: Text('ID')),
                            DataColumn(label: Text('Hotel POI')),
                            DataColumn(label: Text('Check-in Date')),
                            DataColumn(label: Text('Check-out Date')),
                            DataColumn(label: Text('Number of People')),
                            DataColumn(label: Text('Fare')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _hotels.map((hotel) {
                            return DataRow(cells: [
                              DataCell(Text(hotel['id'].toString())),
                              DataCell(Text(hotel['hotel_poi'])),
                              DataCell(Text(hotel['checkin_date'])),
                              DataCell(Text(hotel['checkout_date'])),
                              DataCell(
                                  Text(hotel['number_of_people'].toString())),
                              DataCell(Text(hotel['fare'].toString())),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () => _showEditDialog(hotel),
                                  child: const Text('Edit'),
                                ),
                              ),
                            ]);
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _logout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
