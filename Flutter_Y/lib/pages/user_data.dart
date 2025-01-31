import 'package:easelink/pages/profile.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class User {
  final String email;
  final String name;
  final String username;
  final String phone;
  final String gender;
  final String avatarUrl;

  User({
    required this.email,
    required this.name,
    required this.username,
    required this.phone,
    required this.gender,
    required this.avatarUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      email: json['email'],
      name: json['fullname'],
      username: json['username'],
      phone: json['phone'],
      gender: json['gender'],
      avatarUrl: json['avatarUrl'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'fullname': name,
      'username': username,
      'phone': phone,
      'gender': gender,
      'avatarUrl': avatarUrl,
    };
  }
}

class UserDataPage extends StatefulWidget {
  @override
  _UserDataPageState createState() => _UserDataPageState();
}

class _UserDataPageState extends State<UserDataPage> {
  final emailController = TextEditingController();
  final fullNameController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  String? selectedGender;

  Map<String, bool> isEditing = {
    'Full Name': false,
    'Username': false,
    'Email': false,
    'Phone': false,
  };

  //---------------------------------------IMAGE PICKER---------------------------------------------------
  
  
  
 
 final picker = ImagePicker();
  
 
  String? avatarPath;
//   @override
//   void initState() {
//     super.initState();
//     _loadAvatarPath();
//   }

//   Future<void> _loadAvatarPath() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       avatarPath = prefs.getString('avatar_path');
//     });
//   }

  Future<void> pickImage() async {
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        final appDir = await getApplicationDocumentsDirectory();
        final fileName = pickedFile.path.split('/').last;
        final savedImage = File('${appDir.path}/$fileName');
        await File(pickedFile.path).copy(savedImage.path);

        final prefs = await SharedPreferences.getInstance();
        // await prefs.setString('avatar_path', savedImage.path);

        setState(() {
          var avatarPath = savedImage.path;
        });

        // Send the new avatar path to the server
        final accessToken = prefs.getString('access_token');
        if (accessToken != null) {
          final url = Uri.parse('http://192.168.1.108:8000/profile/');
          final response = await http.post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $accessToken',
            },
            body: json.encode({'avatarUrl': savedImage.path}),
          );

          if (response.statusCode == 200) {
            print('Avatar updated successfully');
          } else {
            print('Failed to update avatar: ${response.statusCode}');
          }
        }

        print('Image saved at: ${savedImage.path}');
      } else {
        print('No image picked');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  //----------------------------------------------------------------------------------------------------------

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        print('getCurrentUser: No access token found');
        Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
        return null; // No token found, user is not logged in
      }

      final url = Uri.parse('http://192.168.1.108:8000/profile/');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('getCurrentUser: Data fetched successfully: $data');
        return User.fromJson(data);
      } else if (response.statusCode == 401) {
        print('getCurrentUser: Access token expired, refreshing...');
        await _refreshToken();
        return getCurrentUser();
      } else {
        print('getCurrentUser: Failed to load user: ${response.statusCode}');
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting current user: $e');
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
      return null;
    }
  }

  Future<void> _refreshToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refresh_token');

      if (refreshToken == null) {
        print('No refresh token found');
        Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
        return;
      }

      final url = Uri.parse('http://127.0.0.1:8000/token/refresh/');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'grant_type': 'refresh_token',
          'refresh_token': refreshToken,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await prefs.setString('access_token', data['access_token']);
        print('Token refreshed successfully');
      } else {
        print('Failed to refresh token: ${response.statusCode}');
        Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
      }
    } catch (e) {
      print('Error refreshing token: $e');
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
    }
  }

  Future<void> updateUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('access_token');

    if (accessToken == null) {
      print('updateUser: No access token found');
      Navigator.pushReplacementNamed(context, '/Flutter_Y/lib/pages/login.dart');
      return; // No token found, user is not logged in
    }

    final url = Uri.parse('http://192.168.1.108:8000/profile/update/'); // Ensure this endpoint is correct
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: json.encode(user.toJson()),
    );

    if (response.statusCode == 200) {
      print('User updated successfully');
    } else {
      print('Failed to update user: ${response.statusCode}');
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }

Widget buildEditableField(String label, TextEditingController controller, String title, IconData icon, Color colo) {
  return Container(
    padding: const EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 29, 27, 27),
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 2,
          blurRadius: 5,
          offset: Offset(0, 3), // changes position of shadow
        ),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: colo),
              filled: true,
              fillColor: const Color.fromARGB(255, 29, 27, 27),
              contentPadding: const EdgeInsets.all(15),
              hintText: 'Enter Your $title',
              hintStyle: const TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
            enabled: isEditing[label],
            style: TextStyle(
              color: Colors.white, // Change this to your desired text color
            ),
          ),
        ),
        IconButton(
          icon: Icon(isEditing[label]! ? Icons.save : Icons.arrow_forward_ios, color: Color.fromARGB(255, 255, 255, 255)),
          onPressed: () {
            if (isEditing[label]!) {
              final updatedUser = User(
                name: fullNameController.text,
                username: usernameController.text,
                email: emailController.text,
                phone: phoneController.text,
                gender: selectedGender!,
                avatarUrl: avatarPath ?? 'Null',
              );
              updateUser(updatedUser);
            }
            setState(() {
              isEditing[label] = !isEditing[label]!;
              
            });
          },
        ),
      ],
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Edit Profile'), centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_outlined, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          },
        ),
        ),

        



      body: FutureBuilder<User?>(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData) {
            return Center(child: Text('Error loading profile'));
          }

          final user = snapshot.data!;
          emailController.text = user.email;
          fullNameController.text = user.name;
          usernameController.text = user.username;
          phoneController.text = user.phone;
          selectedGender = user.gender;
          avatarPath = user.avatarUrl;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  
                  children: [
                    GestureDetector(
                      onTap: pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundImage: (user.avatarUrl == 'Null' || user.avatarUrl.isEmpty)
                          ? AssetImage('assets/images/default_profile.png')
                          : FileImage(File(user.avatarUrl)) as ImageProvider,
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(user.gender, style: TextStyle(fontSize: 16, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Text('Personal Information', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,)),

                
                SizedBox(height: 15),
                buildEditableField('Full Name', fullNameController,'fullName',Icons.person ,const Color.fromARGB(255, 59, 116, 61)),
                SizedBox(height: 10),
                buildEditableField('Username', usernameController,'username',Icons.person_add_alt, const Color.fromARGB(255, 153, 90, 86)),
                SizedBox(height: 10),
                buildEditableField('Email', emailController,'email',Icons.email ,const Color.fromARGB(255, 87, 84, 99)),
                SizedBox(height: 10),
                buildEditableField('Phone', phoneController,'phone',Icons.phone, const Color.fromARGB(255, 26, 112, 183)),
                SizedBox(height: 10),


                Text('Others', style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold,)),
                SizedBox(height: 15),
                buildEditableField('Full Name', fullNameController,'fullName',Icons.person ,const Color.fromARGB(255, 59, 116, 61)),
                SizedBox(height: 10),
                buildEditableField('Username', usernameController,'username',Icons.person_add_alt, const Color.fromARGB(255, 153, 90, 86)),
                SizedBox(height: 10),
                buildEditableField('Email', emailController,'email',Icons.email ,const Color.fromARGB(255, 87, 84, 99)),
                SizedBox(height: 10),
                buildEditableField('Phone', phoneController,'phone',Icons.phone, const Color.fromARGB(255, 26, 112, 183)),
                SizedBox(height: 10),
                // TextFormField(
                //   initialValue: selectedGender,
                //   decoration: InputDecoration(labelText: 'Gender'),
                //   enabled: false,
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
