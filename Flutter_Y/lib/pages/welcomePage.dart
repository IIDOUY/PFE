import 'package:easelink/pages/how_to_use.dart';
import 'package:flutter/material.dart';
 import 'package:easelink/pages/home.dart';
import 'package:easelink/pages/signup.dart';
import 'package:easelink/pages/profile.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'EaseLink',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.normal,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,  // Ensures space is used effectively
          children: [
            // Centered Image (Ensures image is centered on the screen)
            Flexible(
              flex: 1,
              child: Center(
                child: Image.asset(
                  'assets/images/welcome.png', // Replace with your image path
                  // Adjust size
                  
                  fit: BoxFit.contain, // Adjust image scaling
                ),
              ),
            ),
            
            // Text
            const Text(
              'Find The Ideal Service',
              // textAlign: TextAlign.center,
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            const Text(
              'Unlock access to the ultimate app for top-tier services, tailored to meet all your needs seamlessly and efficiently',
              // textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Color.fromARGB(76, 0, 0, 0),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Buttons at the Bottom
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the How To Use page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => HowToUsePage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB3C08), // Button background color
                    foregroundColor: Colors.white, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'How To Use',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Navigate to the Home page
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => SignUpPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent, // Transparent background
                    shadowColor: Colors.transparent, // Remove shadow
                    foregroundColor: Colors.black, // Text color
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16), // Rounded corners
                    ),
                  ),
                  child: const Text(
                    'Skip',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
