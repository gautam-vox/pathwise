import 'dart:convert';
import 'package:pathwise/main.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TaxiAdminPage extends StatefulWidget {
  const TaxiAdminPage({super.key});

  @override
  State<TaxiAdminPage> createState() => _TaxiAdminPageState();
}

class _TaxiAdminPageState extends State<TaxiAdminPage> {
  List<dynamic> _bookings = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  Future<void> _fetchBookings() async {
    final response =
        await http.get(Uri.parse('http://${globals.ipAddress}:8000/get_bookings'));

    if (response.statusCode == 200) {
      setState(() {
        _bookings = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch bookings')),
      );
    }
  }

  void _showEditDialog(Map<String, dynamic> booking) {
    final TextEditingController startPointController =
        TextEditingController(text: booking['start_point']);
    final TextEditingController destinationPointController =
        TextEditingController(text: booking['destination_point']);
    final TextEditingController transportController =
        TextEditingController(text: booking['preferred_transport']);
    final TextEditingController dateController =
        TextEditingController(text: booking['date']);
    final TextEditingController chargeController =
        TextEditingController(text: booking['charge'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Booking'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: startPointController,
                decoration: const InputDecoration(labelText: 'Start Point'),
              ),
              TextField(
                controller: destinationPointController,
                decoration:
                    const InputDecoration(labelText: 'Destination Point'),
              ),
              TextField(
                controller: transportController,
                decoration:
                    const InputDecoration(labelText: 'Preferred Transport'),
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
              ),
              TextField(
                controller: chargeController,
                decoration: const InputDecoration(labelText: 'Charge'),
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
              final updatedBooking = {
                'id': booking['id'],
                'start_point': startPointController.text,
                'destination_point': destinationPointController.text,
                'preferred_transport': transportController.text,
                'date': dateController.text,
                'charge': double.tryParse(chargeController.text),
              };

              final response = await http.post(
                Uri.parse('http://${globals.ipAddress}:8000/update_booking'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(updatedBooking),
              );

              if (response.statusCode == 200) {
                setState(() {
                  _fetchBookings();
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Booking updated successfully')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Failed to update booking')),
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
    // Your logout logic
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginActivity()),
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
                  // Taxi Admin Panel Card
                  Card(
                    color: Colors.grey[200],
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Taxi Admin Panel',
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
                  // DataTable with Border
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
                            DataColumn(label: Text('Username')),
                            DataColumn(label: Text('Start Point')),
                            DataColumn(label: Text('Destination')),
                            DataColumn(label: Text('Transport')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Charge')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows: _bookings.map((booking) {
                            return DataRow(cells: [
                              DataCell(Text(booking['id'].toString())),
                              DataCell(Text(booking['username'])),
                              DataCell(Text(booking['start_point'])),
                              DataCell(Text(booking['destination_point'])),
                              DataCell(Text(booking['preferred_transport'])),
                              DataCell(Text(booking['date'])),
                              DataCell(Text(booking['charge'].toString())),
                              DataCell(
                                ElevatedButton(
                                  onPressed: () => _showEditDialog(booking),
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
                  // Logout Button
                  ElevatedButton(
                    onPressed:
                        _logout, // This triggers the _logout function when the button is pressed
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Background color
                      padding: const EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 40), // Padding for rectangle shape
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(
                            8), // Optional, adds rounded corners if desired
                      ),
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 18, // Font size
                        fontWeight: FontWeight.bold, // Bold font
                        color: Colors.white, // White text color
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
