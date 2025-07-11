import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/globals.dart';
import 'package:flutter_application_2/startscreen.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.subject.toUpperCase()} QnA"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logoutUser,
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
                const CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(Icons.menu, color: Colors.black),
                ),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Most Asked Questions",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      items == null
                          ? "Loading..."
                          : "${items!.length} Question${items!.length == 1 ? '' : 's'}",
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
                        child: ListTile(
                          leading: const Icon(Icons.question_answer),
                          title: Text(task['ques']),
                          subtitle: Text(
                            task['companyname']?.toString().trim().isNotEmpty == true
                                ? task['companyname']
                                : 'No company specified',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          trailing: SizedBox(
                            width: 150,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.thumb_up, color: Colors.green),
                                  onPressed: () async {
                                    setState(() {
                                      task['count'] = (task['count']) + 1;
                                    });
                                    await editTask(
                                      task['_id'],
                                      task['ques'],
                                      task['companyname'],
                                      task['count'],
                                    );
                                    await fetchTasks();
                                  },
                                ),
                                Text("${task['count']}", style: const TextStyle(fontSize: 10)),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () {
                                    if (loggedInEmail == task['useremail']) {
                                      showEditDialog(task);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("You can only edit your own questions.")),
                                      );
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    if (loggedInEmail == task['useremail']) {
                                      await deleteTask(task['_id']);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text("You can only delete your own questions.")),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
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
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: "Question"),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: "Company Name (optional)"),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("ADD"),
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  var reqBody = {
                    'count': 1,
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

  void showEditDialog(Map task) {
    final TextEditingController editQues = TextEditingController(text: task['ques']);
    final TextEditingController editCompany = TextEditingController(text: task['companyname']);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editQues,
                decoration: const InputDecoration(labelText: "Question"),
              ),
              TextField(
                controller: editCompany,
                decoration: const InputDecoration(labelText: "Company Name"),
              ),
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
                await editTask(
                  task['_id'],
                  editQues.text,
                  editCompany.text,
                  task['count'],
                );
                Navigator.of(context).pop();
                fetchTasks();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> editTask(
    String id,
    String newQues,
    String newCompany,
    int count,
  ) async {
    var body = {
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
      fetchTasks();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to delete question.")),
      );
    }
  }
}
