import 'package:flutter/material.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tài khoản của tôi'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'Thông tin người dùng',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
