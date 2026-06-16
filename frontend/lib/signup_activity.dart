import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SignupActivity extends StatefulWidget {
  const SignupActivity({super.key});

  @override
  _SignupActivityState createState() => _SignupActivityState();
}

class _SignupActivityState extends State<SignupActivity> {
  final _formKey = GlobalKey<FormState>();
  String? _purposeOfVisit;
  String? _ageGroup;

  String? _selectedNatureOption;
  String? _selectedhotelOption;
  String? _selectedFoodOption;
  String? _selectedTaxiOption;

  final List<String> _purposes = [
    'Tourism',
    'Family Visit',
    'Education',
    'Adventure',
  ];

  final List<String> _ageGroups = ['18-25', '26-40', '41-60', '60+'];

  final Map<String, List<String>> _pointsOfInterest = {
    'Nature': ['Hills', 'Forests', 'Waterfalls'],
    'hotel': ['Resorts', 'Budget Stays', 'Homestays'],
    'Food': ['Cafes', 'Fine Dining Restaurants', 'Street Food'],
    'Taxi': ['Car', 'Bus transport']
  };

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  Future<void> _sendDataToBackend() async {
    final url = Uri.parse('http://${globals.ipAddress}:8000/submit_signup');

    final data = {
      'full_name': _fullNameController.text,
      'username': _usernameController.text,
      'password': _passwordController.text,
      'email': _emailController.text,
      'purpose_of_visit': _purposeOfVisit,
      'age_group': _ageGroup,
      'poi_nature': _selectedNatureOption,
      'poi_hotel': _selectedhotelOption,
      'poi_food': _selectedFoodOption,
      'poi_taxi': _selectedTaxiOption,
    };

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Signup successful: ${responseData['message']}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Center(
          child: Text(
            'Pathwise',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background Image
          SizedBox.expand(
            child: Image.asset(
              'assets/moonsky.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Transparent overlay
          Container(
            color: Colors.black.withOpacity(0.5),
          ),
          SingleChildScrollView(
            child: Center(
              child: Card(
                elevation: 5,
                margin:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Registration',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Full Name
                        TextFormField(
                          controller: _fullNameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your full name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Username
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            labelText: 'Username',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Password
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Email Address
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email Address',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Purpose of Visit
                        DropdownButtonFormField<String>(
                          value: _purposeOfVisit,
                          decoration: const InputDecoration(
                            labelText: 'Purpose of Visit',
                            border: OutlineInputBorder(),
                          ),
                          items: _purposes.map((String purpose) {
                            return DropdownMenuItem<String>(
                              value: purpose,
                              child: Text(purpose),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _purposeOfVisit = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select the purpose of your visit';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // Age Group Dropdown
                        DropdownButtonFormField<String>(
                          value: _ageGroup,
                          decoration: const InputDecoration(
                            labelText: 'Age Group',
                            border: OutlineInputBorder(),
                          ),
                          items: _ageGroups.map((String ageGroup) {
                            return DropdownMenuItem<String>(
                              value: ageGroup,
                              child: Text(ageGroup),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _ageGroup = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select your age group';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),
                        // POI Card
                        Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Points of Interest',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                // Nature Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedNatureOption,
                                  decoration: const InputDecoration(
                                    labelText: 'Nature',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _pointsOfInterest['Nature']!
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedNatureOption = newValue;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                DropdownButtonFormField<String>(
                                  value: _selectedhotelOption,
                                  decoration: const InputDecoration(
                                    labelText: 'hotel',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _pointsOfInterest['hotel']!
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedhotelOption = newValue;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),

                                // Nature Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedTaxiOption,
                                  decoration: const InputDecoration(
                                    labelText: 'Taxi',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _pointsOfInterest['Taxi']!
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedTaxiOption = newValue;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                // Food Dropdown
                                DropdownButtonFormField<String>(
                                  value: _selectedFoodOption,
                                  decoration: const InputDecoration(
                                    labelText: 'Food',
                                    border: OutlineInputBorder(),
                                  ),
                                  items: _pointsOfInterest['Food']!
                                      .map((String option) {
                                    return DropdownMenuItem<String>(
                                      value: option,
                                      child: Text(option),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedFoodOption = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _sendDataToBackend();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            minimumSize: const Size(150, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            backgroundColor:
                                const Color.fromARGB(255, 13, 247, 44),
                          ),
                          child: const Text(
                            'Signup',
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
