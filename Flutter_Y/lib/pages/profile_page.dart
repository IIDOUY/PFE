import 'dart:io';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';  // Pour Flutter Web
import 'package:flutter/foundation.dart'; // Vérifie si l'on est sur Web



class ProfilePage2 extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage2> {
  File? _image;
  String? _profileImageUrl;
  String _fullname = "Loading...";
  String _email = "Loading...";
  String _username = "Loading...";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  // 📌 Sélectionner une image depuis la galerie
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      _uploadProfilePicture();
    }
  }

  // 📌 Envoyer la photo de profil au backend Django
  Future<void> _uploadProfilePicture() async {
  final prefs = await SharedPreferences.getInstance();
  final accessToken = prefs.getString('access_token');

  if (accessToken == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User not authenticated.')),
    );
    return;
  }

  final ImagePicker picker = ImagePicker();
  XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

  if (pickedFile == null) return;  // Si l'utilisateur annule la sélection

  Uri url = Uri.parse('http://127.0.0.1:8000/profile/');

  var request = http.MultipartRequest('PUT', url);
  request.headers['Authorization'] = 'Bearer $accessToken';

  if (kIsWeb) {
    // ✅ Pour Flutter Web : Convertir en `bytes`
    Uint8List bytes = await pickedFile.readAsBytes();
    request.files.add(http.MultipartFile.fromBytes(
      'profile_picture', bytes,
      filename: 'profile.jpg',  // Un nom arbitraire pour l'image
    ));
  } else {
    // ✅ Pour Android/iOS : Utiliser `fromPath()`
    request.files.add(await http.MultipartFile.fromPath(
      'profile_picture', pickedFile.path,
    ));
  }

  try {
    var response = await request.send();
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile picture updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile picture.')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  // 📌 Récupérer le profil utilisateur
  Future<void> _fetchUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/profile/'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = Map<String, dynamic>.from(jsonDecode(response.body));
      setState(() {
        _fullname = data['fullname'];
        _email = data['email'];
        _username = data['username'];
        _profileImageUrl = data['profile_picture'];
        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to load profile.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Profile Page")),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profileImageUrl != null
                        ? NetworkImage(_profileImageUrl!)
                        : AssetImage("assets/images/default.jpg") as ImageProvider,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text("Full Name: $_fullname"),
                Text("Username: $_username"),
                Text("Email: $_email"),
              ],
            ),
    );
  }
  
}
