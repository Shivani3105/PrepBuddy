import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/globals.dart';
import 'package:flutter_application_2/subjectpage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // ✅ Fixed import
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
  bool isLoading = false;
  String? debugMessage;

  void loginUser() async {
    setState(() {
      isLoading = true;
      _isNotValidate = false;
      debugMessage = null;
    });

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
          final jsonResponse = jsonDecode(response.body);
          if (jsonResponse['status'] == true && jsonResponse['token'] != null) {
            myToken = jsonResponse['token'];
            await prefs.setString('token', myToken!);

            setState(() {
              debugMessage = "✅ Login successful!";
            });

            if (context.mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SubjectPage()),
              );
            }
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
          debugMessage = "Something went wrong. Try again.";
        });
      }
    } else {
      setState(() {
        _isNotValidate = true;
        debugMessage = "Email or password cannot be empty.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Sign In")),
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
