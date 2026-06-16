import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'home_page.dart';
import 'main.dart';
import 'schedule.dart';
import 'globals.dart' as globals;


class EditProfile extends StatefulWidget {
  const EditProfile({Key? key}) : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  final _formKey = GlobalKey<FormState>();

  String _username = '';
  String _fullName = '';
  String _email = '';
  String _purposeOfVisit = '';
  String _ageGroup = '';
  String _naturePoi = '';
  String _hotelPoi = '';
  String _foodPoi = '';
  String _taxiPoi = '';
  String _password = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final username = prefs.getString('username') ?? '';

      if (username.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No username found in SharedPreferences.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(f'http://${globals.ipAddress}:8000/get_profile?username=$username'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          final user = responseData['user'];
          setState(() {
            _username = user['username'] ?? '';
            _fullName = user['full_name'] ?? '';
            _email = user['email'] ?? '';
            _purposeOfVisit = user['purpose_of_visit'] ?? '';
            _ageGroup = user['age_group'] ?? '';
            _naturePoi = user['nature_poi'] ?? '';
            _hotelPoi = user['hotel_poi'] ?? '';
            _foodPoi = user['food_poi'] ?? '';
            _taxiPoi = user['taxi_poi'] ?? '';
            _isLoading = false;
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(responseData['message'] ?? 'Error loading data')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to load user data. Status code: ${response.statusCode}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitProfileUpdate() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        final response = await http.put(
          Uri.parse('http://${globals.ipAddress}:8000/edit_profile'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': _username,
            'full_name': _fullName,
            'email': _email,
            'purpose_of_visit': _purposeOfVisit,
            'age_group': _ageGroup,
            'nature_poi': _naturePoi,
            'hotel_poi': _hotelPoi,
            'food_poi': _foodPoi,
            'taxi_poi': _taxiPoi,
            'password': _password,
          }),
        );

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseData['message'] ?? 'Profile updated successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    responseData['message'] ?? 'Failed to update profile')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
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
              color: Colors.white,
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
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: const Text('Map'),
              onTap: () {},
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
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                prefs.remove('username');

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const LoginActivity()),
                );
              },
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField('Full Name', _fullName,
                                (value) => _fullName = value!),
                            _buildTextField(
                                'Email', _email, (value) => _email = value!),
                            _buildTextField('Purpose of Visit', _purposeOfVisit,
                                (value) => _purposeOfVisit = value!),
                            _buildTextField('Age Group', _ageGroup,
                                (value) => _ageGroup = value!),
                            _buildTextField('Nature POI', _naturePoi,
                                (value) => _naturePoi = value!),
                            _buildTextField('Hotel POI', _hotelPoi,
                                (value) => _hotelPoi = value!),
                            _buildTextField('Food POI', _foodPoi,
                                (value) => _foodPoi = value!),
                            _buildTextField('Taxi POI', _taxiPoi,
                                (value) => _taxiPoi = value!),
                            _buildPasswordField(
                                'Password', (value) => _password = value!),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _submitProfileUpdate,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Update',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
      String label, String initialValue, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        initialValue: initialValue,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField(String label, Function(String?) onSaved) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: TextFormField(
        obscureText: true,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onSaved: onSaved,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }
}
