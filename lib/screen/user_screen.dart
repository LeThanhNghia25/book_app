import 'package:book_app/screen/read_screen.dart';
import 'package:flutter/material.dart';

import 'chapter_screen.dart';
import 'base_screen.dart';

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

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      routes: {
        '/chapters': (context) => ChapterScreen(),
        '/read': (context) => ReadScreen(),
        '/user': (context) => UserScreen()
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: UserScreen(),
    );
  }
}