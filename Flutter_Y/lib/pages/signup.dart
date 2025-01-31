import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'home.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  String fullName = '';
  String username = '';
  String email = '';
  String password = '';
  String confirmPassword = '';
  String phone = '';
  String gender = 'Select your Gender'; // Default value for gender
  bool is_vip = false;

  //Django
  Future<void> _signUp() async {
  final url = Uri.parse('http://192.168.1.108:8000/signup/');
  
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},

    body: json.encode({
      'fullname': fullName,
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'gender': gender,
    }),
  );

  if (response.statusCode == 201) {
	final data = json.decode(response.body);
	final prefs = await SharedPreferences.getInstance();
    // Stocker les tokens localement
    // await prefs.setString('user_id', data['user']['id']);//added
    await prefs.setString('access_token', data['access_token']);
    await prefs.setString('refresh_token', data['refresh_token']);
    // await prefs.setString('user_id', data['user']['id'].toString()); // Store user ID
        if (data.containsKey('user') && data['user'].containsKey('id')) {
      await prefs.setString('user_id', data['user']['id'].toString());
    } else {
      print('Error: User ID not found in the response');
      // Handle the error appropriately, e.g., show a message to the user
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User created successfully!')),
    );
	// Rediriger vers la page principale (Dashboard)
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => MyHomePage(),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to create user!')),
    );
  }
}

// Future<void> getProtectedData(String accessToken) async {
//   final url = Uri.parse('http://127.0.0.1:8000/protected/');

//   final response = await http.get(
//     url,
//     headers: {'Authorization': 'Bearer $accessToken'},
//   );

//   if (response.statusCode == 200) {
//     print('Data: ${response.body}');
//   } else {
//     print('Error: ${response.statusCode}');
//   }
// }
//Django

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'EaseLink',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.normal,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LogInPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB3C08),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Log In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Text(
                  'Create new \nAccount',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 37,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20),
                // Full Name Field
                                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Your Full Name',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
                    fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                ),
                  ),
                  onChanged: (value) => fullName = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your full name';
                    }else if(RegExp(r'[0-9]').hasMatch(value)){
                      return 'Your Full name should not contains Numbers';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Username Field
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    // fillColor: const Color.fromARGB(121, 84, 77, 77),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Your UserName',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide.none,
                    // ),
                    fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  ),
                  onChanged: (value) => username = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Email Field
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    // fillColor: const Color.fromARGB(121, 84, 77, 77),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Your Email Address',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide.none,
                    // ),
                    fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  ),
                  onChanged: (value) => email = value,
                  validator: (value) {
                    if (value == null || value.isEmpty || !value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Password Field
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    // fillColor: const Color.fromARGB(121, 84, 77, 77),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Your Password',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide.none,
                    // ),
                    fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  ),
                  obscureText: true,
                  onChanged: (value) => password = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                // Confirm Password Field
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    // fillColor: const Color.fromARGB(121, 84, 77, 77),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Confirm Your Password',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
                    // border: OutlineInputBorder(
                    //   borderRadius: BorderRadius.circular(15),
                    //   borderSide: BorderSide.none,
                    // ),
                    fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                  ),
                  obscureText: true,
                  onChanged: (value) => confirmPassword = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != password) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
        
              DropdownButtonFormField<String>(
                value: gender,
                decoration: InputDecoration(
                filled: true, // accept coloring inside the box
                //  fillColor: const Color.fromARGB(121, 84, 77, 77),
                 contentPadding: const EdgeInsets.all(15),
                 prefixIcon: const Icon(Icons.male_outlined , color: Color.fromARGB(255, 0, 0, 0)),
           
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(15), // border radius
              //   borderSide: BorderSide.none,// border sides 
              //   ),
              fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                onChanged: (String? newValue) {
                  setState(() {
                    gender = newValue!;
                  });
                },
                


                
                items: ['Male', 'Female', 'Select your Gender'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    
                    child: Text(value),
                    
                  );
                }).toList(),
                validator: (value) {
                  if (value ==  'Select your Gender') {
                    return 'Please select a gender';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                decoration: InputDecoration(
                filled: true, // accept coloring inside the box
                //  fillColor: const Color.fromARGB(121, 84, 77, 77),
                 contentPadding: const EdgeInsets.all(15),
                 prefixIcon: const Icon(Icons.phone_android_outlined , color: Color.fromARGB(255, 0, 0, 0)),
                 hintText: 'Enter Your Phone Number', // hint text
                 hintStyle: const TextStyle(
                 color: Color.fromARGB(196, 0, 0, 0),
              ),
              // border: OutlineInputBorder(
              //   borderRadius: BorderRadius.circular(15), // border radius
              //   borderSide: BorderSide.none,// border sides 
              //   ),
              fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
                onChanged: (value) => phone = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
                // Other fields...
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signUp();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB3C08),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Sign Up',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

