import 'dart:convert';
import 'package:easelink/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile(); // Fetch user data when the page loads
  }

  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      // Redirect to the login page if no token is found
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dartlogin');
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/profile/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken', // Send access token
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userProfile = json.decode(response.body);
          isLoading = false;
        });
      } else if (response.statusCode == 401) {
        // Token expired or invalid, refresh the token
        await _refreshAccessToken();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  Future<void> _refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');

    if (refreshToken == null) {
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
      return;
    }

    final url = Uri.parse('http://127.0.0.1:8000/token/refresh/');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access']);
        await _fetchUserProfile(); // Reload user data
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session expired. Please log in again.')),
        );
        Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_outlined, color: Color.fromARGB(255, 0, 0, 0)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
            );
          },
        ),
        actions: [
          const Icon(Icons.settings, color: Color.fromARGB(255, 0, 0, 0)),
          const SizedBox(width: 16),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ProfileInfo(userProfile: userProfile!),
                      StatsSection(),
                      // ✅ Vérification si l'utilisateur est VIP
                      if (userProfile!['is_vip'] == true) VIPFeatures(),

                    ],
                  ),
                )
              : const Center(child: Text('Failed to load profile')),
    );
  }
}

class ProfileInfo extends StatelessWidget {
  final Map<String, dynamic> userProfile;

  const ProfileInfo({required this.userProfile});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center, // Align content to center
      children: [
        Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            image: const DecorationImage(
              image: AssetImage("assets/images/real.jpg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage("assets/images/valverdi.jpg"),
              backgroundColor: Colors.white,
            ),
            const SizedBox(height: 8),
            Text(
              userProfile['fullname'] ?? 'Unknown',
              style: const TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              userProfile['username'] ?? 'Unknown',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ],
    );
  }
}
class VIPBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Learn more about exclusive VIP privileges",
            style: TextStyle(color: Colors.purple, fontSize: 16),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(backgroundColor: const Color.fromARGB(255, 0, 0, 0)),
            child: Text(
              "View Now",
              style: TextStyle(color: Colors.purple),
            ),
          ),
        ],
      ),
    );
  }
}



class StatsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("0", "Ongoing"),
          _buildStatItem("9", "Finished"),
          _buildStatItem("4", "Later"),
          _buildStatItem("13", "Total"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(color: const Color.fromARGB(255, 0, 0, 0), fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey),
        ),
      ],
    );
  }
}

class VIPFeatures extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.purple[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "VIP Features",
                style: TextStyle(color: const Color.fromARGB(255, 255, 255, 255), fontSize: 18, fontWeight: FontWeight.bold),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 216, 11, 42)),
                child: Text("See all VIP Features", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          SizedBox(height: 16),
          _buildFeatureRow("Unlimited Services", true),
          _buildFeatureRow("Unlock More Features", true),
          _buildFeatureRow("a khoya t9adaw liya hhh", true),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature, bool isAvailable) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            feature,
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Icon(
            isAvailable ? Icons.check : Icons.close,
            color: isAvailable ? Colors.green : Colors.red,
          ),
        ],
      ),
    );
  }
}