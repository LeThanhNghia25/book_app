import 'package:flutter/material.dart';

Widget buildFooter() {
  return Container(
    padding: EdgeInsets.all(16),
    color: Colors.grey[200],
    child: Center(
      child: Text('© 2024 Book App', style: TextStyle(color: Colors.black54)),
    ),
  );
}