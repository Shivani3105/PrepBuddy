import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/dashboard.dart';
import 'package:flutter_application_2/subjectpage.dart';
import 'package:flutter_application_2/startscreen.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'globals.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isTokenValid() async {
    final prefs = await SharedPreferences.getInstance();
    myToken = prefs.getString('token');

    if (myToken == null || myToken!.isEmpty || JwtDecoder.isExpired(myToken!)) {
      return false;
    } else {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: false,
      ),
      home: FutureBuilder<bool>(
        future: isTokenValid(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.data == true) {
              return SubjectPage(); // ✅ token valid
            } else {
              return const StartScreen(); // ❌ token missing or expired
            }
          }
        },
      ),
    );
  }
}
