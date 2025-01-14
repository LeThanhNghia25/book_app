import 'package:flutter/material.dart';

class FloatingChatbotIcon extends StatefulWidget {
  final VoidCallback onTap;

  const FloatingChatbotIcon({super.key, required this.onTap});

  @override
  _FloatingChatbotIconState createState() => _FloatingChatbotIconState();
}

class _FloatingChatbotIconState extends State<FloatingChatbotIcon> {
  double _x = 370; // Vị trí ban đầu theo trục X
  double _y = 700; // Vị trí ban đầu theo trục Y

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _x,
      top: _y,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            // Cập nhật vị trí của icon khi người dùng kéo
            _x += details.delta.dx;
            _y += details.delta.dy;
          });
        },
        onTap: widget.onTap, // Hành động khi nhấn vào icon
        child: CircleAvatar(
          backgroundColor: Colors.deepOrange,
          radius: 30,
          child: const Icon(Icons.chat, color: Colors.white, size: 30),
        ),
      ),
    );
  }
}
