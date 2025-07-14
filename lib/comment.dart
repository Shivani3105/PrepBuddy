import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/config.dart';
import 'package:flutter_application_2/startscreen.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Comments extends StatefulWidget {
  final String questionId;

  const Comments({super.key, required this.questionId});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  List<dynamic>? comments = [];
  String? loggedInUserName;

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
      final userId = decoded['_id'];

      final response = await http.post(
        Uri.parse(getUser),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"_id": userId}),
      );
      print(userId);
      print("*****************");
      print(response.body);
      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        loggedInUserName = data['success']['username'];
        print(loggedInUserName);
      } else {
        loggedInUserName = null;
      }
    }

    await fetchComments();
  }

  Future<void> fetchComments() async {
    try {
      var regBody = {"_id": widget.questionId};
      var response = await http.post(
        Uri.parse(getComment),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(regBody),
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        Map<String, dynamic> commentMap =
            Map<String, dynamic>.from(jsonResponse['success']);

        setState(() {
          comments = commentMap.entries
              .map((entry) => {'username': entry.key, 'comment': entry.value})
              .toList();
        });
      } else {
        setState(() => comments = []);
      }
    } catch (e) {
      setState(() => comments = []);
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

  void onPressedFunc() {
    if (loggedInUserName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in! Please sign in.")),
      );
      return;
    }

    final TextEditingController commentController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Comment"),
          content: TextField(
            controller: commentController,
            decoration: const InputDecoration(labelText: "Comment"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("ADD"),
              onPressed: () async {
                if (commentController.text.isNotEmpty) {
                  var reqBody = {
                    'comment': commentController.text,
                    'username': loggedInUserName,
                    '_id': widget.questionId,
                  };

                  var response = await http.post(
                    Uri.parse(addComment),
                    headers: {"Content-Type": "application/json"},
                    body: jsonEncode(reqBody),
                  );

                  if (response.statusCode == 201) {
                    Navigator.of(context).pop();
                    await Future.delayed(const Duration(milliseconds: 300));
                    await fetchComments();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Failed to add comment.")),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Comments"),
        actions: [
          TextButton.icon(
            onPressed: logoutUser,
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: (comments == null || comments!.isEmpty)
          ? const Center(child: Text("No comments yet."))
          : ListView.builder(
              itemCount: comments!.length,
              itemBuilder: (context, index) {
                final curr = comments![index];
                final isCurrentUser = curr['username'] == loggedInUserName;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  child: ListTile(
                    leading: const Icon(Icons.comment),
                    title: Row(
                      children: [
                        Text(
                          curr['username'] ?? 'Unknown User',
                          style: TextStyle(
                            fontWeight:
                                isCurrentUser ? FontWeight.bold : FontWeight.normal,
                            color: isCurrentUser ? Colors.blue : Colors.black,
                          ),
                        ),
                        if (isCurrentUser)
                          const Text(
                            " (You)",
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      curr['comment']?.toString().trim().isNotEmpty == true
                          ? curr['comment']
                          : 'No comment specified',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        onPressed: onPressedFunc,
        child: const Icon(Icons.add),
      ),
    );
  }
}
