import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/comment.dart';
import 'package:flutter_application_2/getUrQues.dart';
import 'package:flutter_application_2/startscreen.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';
import 'package:intl/intl.dart';

class Dashboard extends StatefulWidget {
  final String subject;
  const Dashboard({super.key, required this.subject});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List? items;
  String? loggedInEmail;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token != null && token.isNotEmpty && !JwtDecoder.isExpired(token)) {
      final decoded = JwtDecoder.decode(token);
      loggedInEmail = decoded['email'];
    } else {
      loggedInEmail = null;
    }

    await fetchTasks();
  }

  Future<void> fetchTasks() async {
    try {
      var regBody = {"subject": widget.subject};
      var response = await http.post(
        Uri.parse(getQnA),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        List fetchedItems = jsonResponse['success'];

        // 🔽 Sort by 'count' descending
        fetchedItems.sort((a, b) => (b['count'] ?? 0).compareTo(a['count'] ?? 0));

        setState(() {
          items = fetchedItems;
        });
      } else {
        setState(() => items = []);
      }
    } catch (e) {
      setState(() => items = []);
    }
  }

  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const StartScreen()),
        (route) => false,
      );
    }
  }

  Future<void> handleUpvote(String quesId) async {
  try {
    var body = {
      "_id": quesId,
      "userId": loggedInEmail, // You are sending this to backend
    };

    var response = await http.post(
      Uri.parse(upvoteuser),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      await fetchTasks(); // Refresh updated data from backend

      if (!result['status']) {
        // Upvote removed
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upvote removed")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed: ${response.body}")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.subject.toUpperCase()} QnA"),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyQuestionsPage()),
              );
            },
            icon: const Icon(Icons.person, color: Colors.white),
            label: const Text('My Questions', style: TextStyle(color: Colors.white)),
          ),
          TextButton.icon(
            onPressed: () => logoutUser(),
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            width: double.infinity,
            color: Colors.lightBlue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu, color: Colors.black),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Most Asked Questions",
                      style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      items == null ? "Loading..." : "${items!.length} Question${items!.length == 1 ? '' : 's'}",
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: (items == null || items!.isEmpty)
                ? const Center(child: Text("No questions yet."))
                : ListView.builder(
                    itemCount: items!.length,
                    itemBuilder: (context, index) {
                      final task = items![index];
                      return Card(
  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
  child: Padding(
    padding: const EdgeInsets.all(10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.question_answer),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task['ques'],
                style: const TextStyle(fontSize: 16),
                softWrap: true,
              ),
              const SizedBox(height: 5),
              Text(
                "Company: ${task['companyname']?.toString().trim().isNotEmpty == true ? task['companyname'] : 'Not specified'}",
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 5),
              Text(
                DateFormat('dd MMM yyyy, hh:mm a')
                    .format(DateTime.parse(task['createdAt']).toLocal()),
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.comment),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Comments(questionId: task['_id']),
                  ),
                );
              },
            ),
            GestureDetector(
  onTap: () => handleUpvote(task['_id']),
  child: Column(
    children: [
      Icon(
        Icons.arrow_upward,
        size: 24,
        color: task['upvotedby'] != null &&
                task['upvotedby'].contains(loggedInEmail)
            ? Colors.blue
            : Colors.grey,
      ),
      Text(
        "${task['count']}",
        style: const TextStyle(fontSize: 10),
      ),
    ],
  ),
),

          ],
        )
      ],
    ),
  ),
);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: () => onPressedFunc(),
        child: const Icon(Icons.add),
      ),
    );
  }

  void onPressedFunc() {
    if (loggedInEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in! Please sign in.")),
      );
      return;
    }

    final TextEditingController titleController = TextEditingController();
    final TextEditingController descController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Question"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: titleController, decoration: const InputDecoration(labelText: "Question")),
              TextField(controller: descController, decoration: const InputDecoration(labelText: "Company Name")),
            ],
          ),
          actions: [
            TextButton(child: const Text("Cancel"), onPressed: () => Navigator.of(context).pop()),
            ElevatedButton(
              child: const Text("ADD"),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  var reqBody = {
                    'count': 0,
                    'subject': widget.subject,
                    'ques': titleController.text,
                    'companyname': descController.text,
                    'useremail': loggedInEmail,
                  };

                  var response = await http.post(
                    Uri.parse(createQnA),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(reqBody),
                  );

                  if (response.statusCode == 201) {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 300));
                    await fetchTasks();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add question.")),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }
}
