import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'signup.dart';
import 'home.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:easelink/pages/home.dart';
import 'package:easelink/pages/resetpassword.dart';

class LogInPage extends StatefulWidget {
  const LogInPage({super.key});
  @override
  _LogInPageState createState() => _LogInPageState();
}
class _LogInPageState extends State<LogInPage> {
  final _formKey = GlobalKey<FormState>();
  String emailOrUsername = '';
  String password = '';

  bool isValidEmail(String input) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
    return emailRegex.hasMatch(input);
  }
  bool isValidUsername(String input) {
    final usernameRegex = RegExp(r"^[a-zA-Z0-9_]{3,15}");
    return usernameRegex.hasMatch(input);
  }

  //Django
  Future<void> _logIn(BuildContext context, String identifier, String password) async {
    if (identifier.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please enter both identifier and password.')),
    );
    return;
  }
    final url = Uri.parse('http://127.0.0.1:8000/login/');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'identifier': emailOrUsername,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final prefs = await SharedPreferences.getInstance();
      // Sauvegarder les tokens localement
      await prefs.setString('access_token', data['access_token']);
      await prefs.setString('refresh_token', data['refresh_token']);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Welcome back, ${data['username']}!')),
      );
      // Redirection vers la page Dashboard
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid email or password.')),
      );
    }
  }


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
                  MaterialPageRoute(builder: (context) => SignUpPage()),
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
                'Sign Up',
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
                  'Glad To See You \n Here Again ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 37,
                    fontWeight: FontWeight.w500,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Email or Username',
                    hintStyle: const TextStyle(
                    color: Color.fromARGB(196, 0, 0, 0),  
                    ),
                  ),
                  onChanged: (value) => emailOrUsername = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter email or username';
                    } else if (!isValidEmail(value) && !isValidUsername(value)) {
                      return 'Enter a valid email or username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    filled: true,
                    //fillColor: const Color.fromARGB(121, 84, 77, 77),
                    contentPadding: const EdgeInsets.all(15),
                    prefixIcon: const Icon(Icons.password, color: Color.fromARGB(255, 0, 0, 0)),
                    hintText: 'Enter Your Password',
                    hintStyle: const TextStyle(
                      color: Color.fromARGB(196, 0, 0, 0),
                    ),
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
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Add login logic here
                      _logIn(context, emailOrUsername, password);
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
                    'Log In',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                                SizedBox(height: 10),
                
              GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) =>  ResetPasswordPage()),  // Navigate to ResetPasswordPage
        );
      },
      
      child: Text(
        'Forgot Password?',
        style: TextStyle(
          color: const Color.fromARGB(255, 0, 0, 0),  // Set color for the link
          fontSize: 14,
          fontWeight: FontWeight.w500,
          decoration: TextDecoration.underline,  // Add underline effect
        ),
      ),
              )

              ],
            ),
          ),
        ),
      ),
    );
  }
}