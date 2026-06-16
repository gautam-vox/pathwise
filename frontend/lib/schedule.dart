import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class BookingSchedulePage extends StatefulWidget {
  @override
  _BookingSchedulePageState createState() => _BookingSchedulePageState();
}

class _BookingSchedulePageState extends State<BookingSchedulePage> {
  String? username;
  Map<String, dynamic>? latestTaxiBooking;
  Map<String, dynamic>? latesthotelBooking;
  Map<String, dynamic>? poiDetails;

  @override
  void initState() {
    super.initState();
    getUsernameAndFetchBookings();
  }

  Future<void> getUsernameAndFetchBookings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');
    });

    if (username != null) {
      await fetchLatestTaxiBooking(username!);
      await fetchLatesthotelBooking(username!);
      await fetchPoiDetails(username!);
    }
  }

  Future<void> fetchLatestTaxiBooking(String username) async {
    final url = Uri.parse(
        'http://${globals.ipAddress}:8000/get_latest_taxi_booking?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          latestTaxiBooking = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching taxi booking: $e');
    }
  }

  Future<void> fetchLatesthotelBooking(String username) async {
    final url = Uri.parse(
        'http://${globals.ipAddress}:8000/get_latest_hotel_booking?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          latesthotelBooking = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching hotel booking: $e');
    }
  }

  Future<void> fetchPoiDetails(String username) async {
    final url = Uri.parse(
        'http://${globals.ipAddress}:8000/get_poi_details?username=$username');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        setState(() {
          poiDetails = jsonDecode(response.body);
        });
      }
    } catch (e) {
      print('Error fetching POI details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: const Text(
          'Booking Schedule',
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: username == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(16),
              child: BookingCard(
                username: username!,
                taxiBooking: latestTaxiBooking,
                hotelBooking: latesthotelBooking,
                poiDetails: poiDetails,
              ),
            ),
    );
  }
}

// 📌 Widget to display all booking details in a single card
class BookingCard extends StatelessWidget {
  final String username;
  final Map<String, dynamic>? taxiBooking;
  final Map<String, dynamic>? hotelBooking;
  final Map<String, dynamic>? poiDetails;

  const BookingCard(
      {required this.username,
      this.taxiBooking,
      this.hotelBooking,
      this.poiDetails});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Booking Details for $username",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Divider(),

            // 🚖 Taxi Booking Details
            Text(
              "🚖 Taxi Booking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            taxiBooking != null
                ? DetailsTable(details: {
                    "Start Point": taxiBooking!['start_point'],
                    "Destination": taxiBooking!['destination_point'],
                    "Transport": taxiBooking!['preferred_transport'],
                    "Date": DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(taxiBooking!['date'])),
                    "Charge": taxiBooking!['charge'],
                  })
                : Text("No recent taxi bookings available"),

            SizedBox(height: 10),

            // 🏨 Hotel Booking Details
            Text(
              "🏨 Hotel Booking",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            hotelBooking != null
                ? DetailsTable(details: {
                    "Hotel": hotelBooking!['hotel_poi'],
                    "Check-in": DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(hotelBooking!['checkin_date'])),
                    "Check-out": DateFormat('yyyy-MM-dd')
                        .format(DateTime.parse(hotelBooking!['checkout_date'])),
                    "People": hotelBooking!['number_of_people'].toString(),
                    "Fare": hotelBooking!['fare'],
                  })
                : Text("No recent hotel bookings available"),

            SizedBox(height: 10),

            // 📍 POI Details
            Text(
              "📍 POI Preferences",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            poiDetails != null
                ? DetailsTable(details: {
                    "Nature POI": poiDetails!['nature_poi'] ?? "Not Available",
                    "Hotel POI": poiDetails!['hotel_poi'] ?? "Not Available",
                    "Food POI": poiDetails!['food_poi'] ?? "Not Available",
                    "Taxi POI": poiDetails!['taxi_poi'] ?? "Not Available",
                  })
                : Text("No POI details found"),
          ],
        ),
      ),
    );
  }
}

// 📌 Widget to display details in a structured table format
class DetailsTable extends StatelessWidget {
  final Map<String, String> details;

  const DetailsTable({required this.details});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: details.entries
          .map(
            (entry) => Padding(
              padding: EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Text(entry.value),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
