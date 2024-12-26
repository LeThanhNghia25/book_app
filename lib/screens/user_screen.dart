import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản của tôi'),
        backgroundColor: const Color(0xFFF44A3E),
      ),
      body: const Center(
        child: Text(
          'Thông tin người dùng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

