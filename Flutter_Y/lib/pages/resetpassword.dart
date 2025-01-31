import 'package:easelink/pages/otp.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ResetPasswordPage extends StatefulWidget {
  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false; // Ajout de l'état de chargement

  // Méthode pour envoyer un code de réinitialisation
  Future<void> _sendResetCode() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorDialog('Veuillez entrer une adresse email valide.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Appel à l'API Django
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/password-reset/send-otp/'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({'email': email}),
      );

      if (response.statusCode == 200) {
        // Succès : Rediriger vers la page OTP
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OtpScreen(email: email),
          ),
        );
      } else {
        // Erreur : Afficher le message d'erreur
        final errorResponse = json.decode(response.body);
        _showErrorDialog(errorResponse['error'] ?? 'Une erreur est survenue.');
      }
    } catch (e) {
      _showErrorDialog('Impossible de contacter le serveur. Vérifiez votre connexion.');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Méthode pour afficher une boîte de dialogue d'erreur
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Erreur'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.asset(
              'assets/images/resetpassword.png',
              height: 150,
            ),
            Text(
              'Reset Your Password',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter your email',
                filled: true,
                fillColor: Colors.white.withOpacity(0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _sendResetCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 240, 58, 3),
                      foregroundColor: Colors.white,
                      padding:
                          EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Reset Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
