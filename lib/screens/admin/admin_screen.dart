import 'package:flutter/material.dart';
import 'manage_users_screen.dart';
import 'manage_books_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Admin Panel',
            style: TextStyle(
              color: Colors.white, // Chữ trắng
              fontWeight: FontWeight.bold, // Chữ in đậm
              fontSize: 20, // Kích thước chữ
            ),
          ),
        ),
        backgroundColor: Colors.red, // Màu nền đỏ
        automaticallyImplyLeading: false, // Loại bỏ nút quay lại (nếu không cần thiết)
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.people, color: Colors.red),
              title: const Text('Quản lý người dùng'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 4,
            child: ListTile(
              leading: const Icon(Icons.book, color: Colors.red),
              title: const Text('Quản lý sách'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ManageBooksScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
