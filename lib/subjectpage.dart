import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_2/startscreen.dart';
import 'dashboard.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key});

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final List<Map<String, dynamic>> subjects = [
    {
      'name': 'Data Structures & Algorithms',
      'short': 'dsa',
      'icon': Icons.device_hub,
      'color': Colors.teal,
    },
    {
      'name': 'Object-Oriented Programming',
      'short': 'oops',
      'icon': Icons.code,
      'color': Colors.blue,
    },
    {
      'name': 'Computer Networks',
      'short': 'cn',
      'icon': Icons.network_wifi,
      'color': Colors.orange,
    },
    {
      'name': 'Database Management Systems',
      'short': 'dbms',
      'icon': Icons.storage,
      'color': Colors.purple,
    },
    {
      'name': 'Operating Systems',
      'short': 'os',
      'icon': Icons.memory,
      'color': Colors.indigo,
    },
  ];

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const StartScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Placement Subjects"),
        centerTitle: true,
        actions: [
          TextButton.icon(
            onPressed: logoutUser,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: subjects.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.2,
        ),
        itemBuilder: (context, index) {
          final subject = subjects[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Dashboard(subject: subject['short']),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: subject['color'].withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 6),
                ],
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(subject['icon'], size: 40, color: Colors.white),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        subject['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
