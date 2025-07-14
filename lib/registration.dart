import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/SignInPage.dart';
import 'package:http/http.dart' as http;
import 'config.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  bool isLoading = false;

  Future<void> registerUser() async {
    final String email = emailController.text.trim();
    final String password = passwordController.text;
    final String username = usernameController.text.trim();

    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are required')),
      );
      return;
    }

    if (!email.contains('@') || !email.endsWith('@gmail.com')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid Gmail address')),
      );
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Username can only contain letters, numbers, and underscores')),
      );
      return;
    }

    if (password.length < 8 || !RegExp(r'^[0-9]+$').hasMatch(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password must be 8+ digits (numeric only)')),
      );
      return;
    }

    setState(() => isLoading = true);

    final Uri url = Uri.parse(reg);
    final Map<String, dynamic> userData = {
      "email": email,
      "password": password,
      "username": username,
    };

    try {
      final http.Response response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(userData),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => SignInPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${response.body}')),
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: "Username"),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 15),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 25),
            ElevatedButton(
              onPressed: isLoading ? null : registerUser,
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Register"),
            ),
          ],
        ),
      ),
    );
  }
}
