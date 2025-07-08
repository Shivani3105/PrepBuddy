import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/dashboard.dart';
import 'package:flutter_application_2/globals.dart';
import 'package:flutter_application_2/subjectpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

class SignInPage extends StatefulWidget {
  
  const SignInPage({super.key});
  
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  late String userToken;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  late SharedPreferences prefs;
  bool _isNotValidate = false;

  @override
  void initState() {
    super.initState();
    initSharedPref();
  }

  void initSharedPref() async {
    prefs = await SharedPreferences.getInstance();
  }

void loginUser() async {
  if (emailController.text.isNotEmpty && passwordController.text.isNotEmpty) {
    var reqBody = {
      'email': emailController.text,
      'password': passwordController.text,
    };

    try {
      var response = await http.post(
        Uri.parse(login),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(reqBody),
      );

      if (response.statusCode == 200) {
        final bodyText = response.body;
        print("Login Response Body: $bodyText");

        final jsonResponse = jsonDecode(bodyText);

        if (jsonResponse['status'] == true && jsonResponse['token'] != null) {
          myToken = jsonResponse['token'];
          prefs.setString('token', myToken!);

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SubjectPage()),
            
            //Dashboard(token: myToken)),
          );
        } else {
          print("Invalid login credentials.");
        }
      } else {
        print("Server returned ${response.statusCode}");
      }
    } catch (e) {
      print("Error parsing response: $e");
    }
  } else {
    setState(() {
      _isNotValidate = true;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: "Email",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                loginUser();
              },
              child: const Text("Sign In"),
            ),
            if (_isNotValidate)
              const Text(
                "Email or Password can't be empty!",
                style: TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
