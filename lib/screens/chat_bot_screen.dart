import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:http/http.dart' as http;
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final String apiKey = "AIzaSyBFJqCBjhCk4v0Z-Ie68fNvJO7yYqRq7Zo";  // Thay bằng API Key của bạn
  final FocusNode _focusNode = FocusNode();

  // Gửi tin nhắn đến API của AI Studio
  Future<void> _sendMessage(String message) async {
    if (message.trim().isEmpty) return;

    _updateMessages("user", message);
    _messageController.clear();

    try {
      final String apiUrl = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent";

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "message": message,
          "language": "vi, en",  // Ngôn ngữ có thể thay đổi
        }),
      );
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final String botReply = responseData['response'] ?? "Không có phản hồi.";

        _updateMessages("bot", botReply);
      } else {
        _updateMessages("bot", "Có lỗi xảy ra! Vui lòng thử lại sau.");
      }
    } catch (e) {
      print('Error: $e');
      _updateMessages("bot", "Lỗi kết nối mạng. Vui lòng kiểm tra kết nối của bạn.");
    }
  }

  // Cập nhật tin nhắn vào danh sách
  void _updateMessages(String sender, String message) {
    setState(() {
      _messages.add({"sender": sender, "text": message});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose(); // Giải phóng tài nguyên khi không cần thiết
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final keyboardVisibility = MediaQuery.of(context).viewInsets.bottom > 0;

    return KeyboardVisibilityProvider(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("AI Studio Chatbot"),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["sender"] == "user";
                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue : Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        message["text"] ?? "",
                        style: TextStyle(color: isUser ? Colors.white : Colors.black),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (!keyboardVisibility) // Đảm bảo phần dưới không bị thay đổi khi bàn phím xuất hiện
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        focusNode: _focusNode,
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: "Nhập tin nhắn...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      icon: const Icon(Icons.send),
                      color: Colors.blue,
                      onPressed: () {
                        _sendMessage(_messageController.text.trim());
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
