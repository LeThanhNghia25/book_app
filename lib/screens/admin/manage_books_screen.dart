import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../../controllers/manage_books_controller.dart';
import '../../models/book.dart';

class ManageBooksScreen extends StatefulWidget {
  const ManageBooksScreen({super.key});

  @override
  State<ManageBooksScreen> createState() => _ManageBooksScreenState();
}

class _ManageBooksScreenState extends State<ManageBooksScreen> {
  late final ManageBooksController _booksController;
  late Future<List<Book>> _booksFuture;

  @override
  void initState() {
    super.initState();
    final database = FirebaseDatabase.instance;
    _booksController = ManageBooksController(database);
    _booksFuture = _booksController.fetchAllBooks();
  }

  // Hiển thị dialog để chỉnh sửa hoặc thêm sách
  void _showBookDialog({Book? book}) {
    final nameController = TextEditingController(text: book?.name ?? '');
    final categoryController = TextEditingController(text: book?.category ?? '');
    final imageController = TextEditingController(text: book?.image ?? '');
    final descriptionController =
    TextEditingController(text: book?.description ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book == null ? 'Thêm sách' : 'Chỉnh sửa sách'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Tên sách'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Thể loại'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(labelText: 'Ảnh bìa (URL)'),
              ),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(labelText: 'Mô tả sách'),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final updatedData = {
                  'Name': nameController.text.trim(),
                  'Category': categoryController.text.trim(),
                  'Image': imageController.text.trim(),
                  'Description': descriptionController.text.trim(),
                };

                try {
                  if (book == null) {
                    // Thêm sách mới
                    final newBook = Book(
                      name: updatedData['Name'],
                      category: updatedData['Category'],
                      image: updatedData['Image'],
                      description: updatedData['Description'],
                    );
                    await _booksController.addBookAutoId(newBook);
                  } else {
                    // Cập nhật sách
                    await _booksController.updateBook(book.id!, updatedData);
                  }

                  setState(() {
                    _booksFuture = _booksController.fetchAllBooks();
                  });
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Lỗi: ${e.toString()}')),
                  );
                } finally {
                  Navigator.pop(context);
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Manage Books',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<Book>>(
        future: _booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books found.'));
          } else {
            final books = snapshot.data!;
            return ListView.builder(
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(book.image ?? ''),
                  ),
                  title: Text(book.name ?? 'Không có tiêu đề'),
                  subtitle: Text(book.category ?? 'Không có danh mục'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showBookDialog(book: book);
                      } else if (value == 'delete') {
                        _booksController.deleteBook(book.id!).then((_) {
                          setState(() {
                            _booksFuture = _booksController.fetchAllBooks();
                          });
                        });
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Chỉnh sửa'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Xóa'),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showBookDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
