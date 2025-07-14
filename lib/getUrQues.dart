import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/config.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class MyQuestionsPage extends StatefulWidget {
  const MyQuestionsPage({super.key});

  @override
  State<MyQuestionsPage> createState() => _MyQuestionsPageState();
}

class _MyQuestionsPageState extends State<MyQuestionsPage> {
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
      await fetchUserQuestions();
    }
  }

  Future<void> fetchUserQuestions() async {
    try {
      final body = {'email': loggedInEmail};
      final response = await http.post(
        Uri.parse(getUserQnA),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        setState(() {
          items = jsonResponse['success'];
        });
      } else {
        setState(() => items = []);
      }
    } catch (e) {
      setState(() => items = []);
    }
  }

  Future<void> handleUpvote(String id) async {
    var body = {
      "_id": id,
      "useremail": loggedInEmail,
    };

    var response = await http.post(
      Uri.parse(upvoteuser), // ensure it's defined in config.dart
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      await fetchUserQuestions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(jsonDecode(response.body)['message'] ?? "Already upvoted"),
        ),
      );
    }
  }

  Future<void> editTask(String id, String newQues, String newCompany, int count) async {
    final body = {
      '_id': id,
      'ques': newQues,
      'companyname': newCompany,
      'count': count,
    };

    final response = await http.put(
      Uri.parse(editQnA),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    if (response.statusCode != 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update question.")),
      );
    }
  }

  Future<void> deleteTask(String id) async {
    final response = await http.delete(
      Uri.parse(deleteQnA(id)),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      await fetchUserQuestions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete question.")),
      );
    }
  }

  void showEditDialog(Map task) {
    final TextEditingController editQues = TextEditingController(text: task['ques']);
    final TextEditingController editCompany = TextEditingController(text: task['companyname']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Question"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: editQues, decoration: const InputDecoration(labelText: "Question")),
              TextField(controller: editCompany, decoration: const InputDecoration(labelText: "Company Name")),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("Update"),
              onPressed: () async {
                await editTask(task['_id'], editQues.text, editCompany.text, task['count']);
                Navigator.of(context).pop();
                await fetchUserQuestions();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Questions"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: items == null || items!.isEmpty
          ? const Center(child: Text("You haven't added any questions yet."))
          : ListView.builder(
              itemCount: items!.length,
              itemBuilder: (context, index) {
                final task = items![index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: ListTile(
                    leading: const Icon(Icons.question_answer),
                    title: Text(task['ques']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Company: ${task['companyname'] ?? 'Not specified'}"),
                        Text("Subject: ${task['subject']}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                    trailing: SizedBox(
                      width: 150,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                           Text(
  DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(task['createdAt'] ?? '')),
  style: const TextStyle(fontSize: 10, color: Colors.grey),
),
                          IconButton(
                            icon: const Icon(Icons.thumb_up, color: Colors.green),
                            onPressed: () => handleUpvote(task['_id']),
                          ),
                          Text("${task['count']}", style: const TextStyle(fontSize: 10)),
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => showEditDialog(task),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async => await deleteTask(task['_id']),
                          ),
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
