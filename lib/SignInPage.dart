import 'dart:convert';
import 'package:flutter/material.dart';
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
  late SharedPreferences prefs;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool _isNotValidate = false;
  String? debugMessage; // 👈 to store text to display

  void loginUser() async {
    prefs = await SharedPreferences.getInstance();

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
          final jsonResponse = jsonDecode(bodyText);

          setState(() {
            debugMessage = "🟢 Token from backend: ${jsonResponse['token']}";
          });

          if (jsonResponse['status'] == true && jsonResponse['token'] != null) {
            myToken = jsonResponse['token'];
            await prefs.setString('token', myToken!);
           String? savedToken = prefs.getString('token');
            print("🟢 Saved token: $savedToken");
            setState(() {
              debugMessage = "✅ Token saved successfully: $myToken";
            });

            // Uncomment this when you're done debugging
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => SubjectPage()),
            );
          } else {
            setState(() {
              debugMessage = "Email or password is incorrect";
            });
          }
        } else {
          setState(() {
            debugMessage = "Email or password is incorrect";
          });
        }
      } catch (e) {
        setState(() {
          debugMessage = "Email or password is incorrect";
        });
      }
    } else {
      setState(() {
        _isNotValidate = true;
        debugMessage = " Email or password cannot be empty.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign In"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
              onPressed: loginUser,
              child: const Text("Sign In"),
            ),
            const SizedBox(height: 20),
            if (_isNotValidate)
              const Text(
                "Email or Password can't be empty!",
                style: TextStyle(color: Colors.red),
              ),

            // ✅ Debug message visible below
            if (debugMessage != null) ...[
              const Divider(),
              Text(
                debugMessage!,
                style: const TextStyle(color: Colors.blue, fontSize: 14),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
