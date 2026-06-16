import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'edit_profile.dart';
import 'main.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late List<Marker> _markers = [];
  late String naturePoi = "", hotelPoi = "", foodPoi = "";
  late String username = "";

  @override
  void initState() {
    super.initState();
    _getUsernameFromSharedPrefs();
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('username'); // Remove username from SharedPreferences
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginActivity()),
    );
  }

  // Method to fetch the username from SharedPreferences
  Future<void> _getUsernameFromSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username') ??
          ''; // Get the username from SharedPreferences
    });

    if (username.isNotEmpty) {
      _fetchPois();
    } else {
      // Handle case where username is not found
      print("Username not found in SharedPreferences.");
    }
  }

  Future<void> _fetchPois() async {
    // Ensure you are using the correct username to fetch POI data
    final response = await http.get(
      Uri.parse('http://${globals.ipAddress}:8000/get_pois/$username'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        naturePoi = data['nature_poi'];
        hotelPoi = data['hotel_poi'];
        foodPoi = data['food_poi'];
        _markers = _getMarkers(naturePoi, hotelPoi, foodPoi);
      });
    } else {
      // Handle error: maybe show a message to the user
      print('Failed to load POIs');
    }
  }

  List<Marker> _getMarkers(String naturePoi, String hotelPoi, String foodPoi) {
    List<Marker> markers = [];

    // Ensure markers are only added based on the current POI data
    if (naturePoi.contains('Forests')) {
      markers.addAll(_buildForestMarkers());
    }
    if (naturePoi.contains('Waterfalls')) {
      markers.addAll(_buildWaterfallMarkers());
    }
    if (naturePoi.contains('Hills')) {
      markers.addAll(_buildHillMarkers());
    }

    if (hotelPoi.contains('Resorts')) {
      markers.addAll(_buildResortMarkers());
    }
    if (hotelPoi.contains('Budget Stays')) {
      markers.addAll(_buildBudgetStayMarkers());
    }
    if (hotelPoi.contains('Homestays')) {
      markers.addAll(_buildHomestayMarkers());
    }

    if (foodPoi.contains('Cafes')) {
      markers.addAll(_buildCafeMarkers());
    }
    if (foodPoi.contains('Fine Dining Restaurants')) {
      markers.addAll(_buildFineDiningMarkers());
    }
    if (foodPoi.contains('Street Food')) {
      markers.addAll(_buildStreetFoodMarkers());
    }

    return markers;
  }

  List<Marker> _buildForestMarkers() {
    return [
      _buildMarker(LatLng(9.0800, 77.1704), 'Konni Reserve Forest',
          'A serene forest reserve in Pathanamthitta.'),
      _buildMarker(LatLng(9.2100, 77.1890), 'Perumthenaruvi Forest',
          'A dense forest reserve near waterfalls.'),
    ];
  }

  List<Marker> _buildWaterfallMarkers() {
    return [
      _buildMarker(LatLng(9.4129, 76.8759), 'Perunthenaruvi Waterfalls',
          'Beautiful scenic waterfall in Pathanamthitta.'),
      _buildMarker(LatLng(9.3380, 76.8550), 'Vazhvanthol Waterfalls',
          'A stunning waterfall surrounded by lush greenery.'),
    ];
  }

  List<Marker> _buildHillMarkers() {
    return [
      _buildMarker(LatLng(9.2646, 76.7948), 'Chuttippara Hill Station',
          'A hill station with breathtaking views.'),
      _buildMarker(LatLng(9.6767, 76.9487), 'Vagamon Hills',
          'A peaceful hill station for nature lovers.'),
    ];
  }

  List<Marker> _buildResortMarkers() {
    return [
      _buildMarker(LatLng(9.6781, 76.9224), 'Mount Tales Vagamon',
          'A serene Resorts in Vagamon, Pathanamthitta.'),
      _buildMarker(LatLng(9.6800, 76.9200), 'Vagamon Lake Resort',
          'A Resorts with a beautiful lake view in Vagamon.'),
    ];
  }

  List<Marker> _buildBudgetStayMarkers() {
    return [
      _buildMarker(LatLng(9.2668, 76.8037), 'Hotel Hills Park',
          'Luxury hotel with great amenities.'),
      _buildMarker(LatLng(9.2650, 76.7950), 'Pathanamthitta Budget Inn',
          'Comfortable budget stay for travelers.'),
    ];
  }

  List<Marker> _buildHomestayMarkers() {
    return [
      _buildMarker(LatLng(9.2689, 76.7923), 'Green Homestay',
          'Comfortable and affordable stay in Pathanamthitta.'),
      _buildMarker(LatLng(9.2750, 76.7700), 'Vasthuhome Homestay',
          'A cozy Homestays with scenic views.'),
    ];
  }

  List<Marker> _buildCafeMarkers() {
    return [
      _buildMarker(LatLng(9.2650, 76.7870), 'Aromas Cafe',
          'Popular for coffee and snacks.'),
      _buildMarker(LatLng(9.2750, 76.8000), 'Coffee Cottage',
          'Perfect spot for a coffee break in Pathanamthitta.'),
    ];
  }

  List<Marker> _buildFineDiningMarkers() {
    return [
      _buildMarker(LatLng(9.2614, 76.7895), 'Aishwarya Hotel',
          'Renowned for authentic Kerala cuisine.'),
      _buildMarker(LatLng(9.2650, 76.7900), 'Sree Mahadeva Restaurant',
          'Delicious South Indian meals and fine dining.'),
    ];
  }

  List<Marker> _buildStreetFoodMarkers() {
    return [
      _buildMarker(LatLng(9.2628, 76.7936), 'KSRTC Snacks Stall',
          'Affordable street food options in Pathanamthitta.'),
      _buildMarker(LatLng(9.2500, 76.7700), 'Pathanamthitta Street Food',
          'Variety of tasty street foods available.'),
    ];
  }

  Marker _buildMarker(LatLng position, String title, String description) {
    return Marker(
      point: position,
      width: 80.0,
      height: 80.0,
      child: GestureDetector(
        onTap: () => _showDetails(title, description),
        child: Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      ),
    );
  }

  void _showDetails(String title, String description) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.local_taxi),
              title: const Text('Taxi Booking'),
              onTap: () {},
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
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: username.isEmpty
          ? Center(child: CircularProgressIndicator())
          : FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(9.272, 76.792),
                initialZoom: 12.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                  subdomains: ['a', 'b', 'c'],
                ),
                MarkerLayer(
                  markers: _markers,
                ),
              ],
            ),
    );
  }
}
