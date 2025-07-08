import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/dashboard.dart';
import 'package:flutter_application_2/subjectpage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'SignInPage.dart';
import 'startscreen.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? storedToken = prefs.getString('token');

  runApp(MyApp(token: storedToken ?? ""));
}

class MyApp extends StatelessWidget {
  final String token;
  const MyApp({Key? key, required this.token}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        useMaterial3: false,
      ),
      home: (token.isEmpty || JwtDecoder.isExpired(token))
          ? const StartScreen()
          : SubjectPage(),
          //Dashboard(token: token),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'subjectpage.dart'; // 👈 Make sure this file exists

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Subject App',
//       theme: ThemeData(
//         primarySwatch: Colors.teal,
//       ),
//       home:  SubjectPage(), // 👈 This is where your custom page runs
//     );
//   }
// }
