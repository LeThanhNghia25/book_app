import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../controllers/manage_users_controller.dart';
import '../../models/user.dart';

class ManageUsersScreen extends StatefulWidget {
  const ManageUsersScreen({super.key});

  @override
  State<ManageUsersScreen> createState() => _ManageUsersScreenState();
}

class _ManageUsersScreenState extends State<ManageUsersScreen> {
  late final ManageUsersController _usersController;
  late Future<List<User>> _usersFuture;

  void _showEditUserDialog(BuildContext context, User user) {
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    final roleController = TextEditingController(text: user.role.toString());
    final avatarController = TextEditingController(text: user.avatar);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit User'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: roleController,
                  decoration: const InputDecoration(labelText: 'Role'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: avatarController,
                  decoration: const InputDecoration(labelText: 'Avatar URL'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': int.tryParse(roleController.text.trim()) ?? user.role,
                  'avatar': avatarController.text.trim(),
                };

                await _usersController.updateUser(user.id, updatedData);
                setState(() {
                  _usersFuture = _usersController.fetchAllUsers();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instance;
    _usersController = ManageUsersController(database);
    _usersFuture = _usersController.fetchAllUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Manage Users',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<User>>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No users found.'));
          } else {
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(user.avatar),
                  ),
                  title: Text(user.name),
                  subtitle: Text(user.email),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditUserDialog(context, user);
                      } else if (value == 'delete') {
                        _usersController.deleteUser(user.id).then((_) {
                          setState(() {
                            _usersFuture = _usersController.fetchAllUsers();
                          });
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),

                );
              },
            );
          }
        },
      ),
    );
  }
}
