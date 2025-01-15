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
    final descriptionController = TextEditingController(text: book?.description ?? '');
    String selectedType = book?.type ?? 'Text'; // Gán giá trị mặc định là 'text'
    List<Chapter> chapters = book?.chapters ?? [];

    final chapterNameController = TextEditingController();
    final chapterContentController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(book == null ? 'Thêm sách' : 'Chỉnh sửa sách'),
          content: SingleChildScrollView(
            child: Column(
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
                Text('Type: $selectedType', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text('Chapters', style: Theme.of(context).textTheme.titleLarge),
                for (int i = 0; i < chapters.length; i++)
                  Column(
                    children: [
                      // Sử dụng TextField để cho phép chỉnh sửa tên chương
                      TextField(
                        controller: TextEditingController(text: chapters[i].name),
                        decoration: const InputDecoration(labelText: 'Tên chương'),
                        onChanged: (value) {
                          chapters[i].name = value; // Cập nhật tên chương
                        },
                      ),
                      // Sử dụng TextField để cho phép chỉnh sửa nội dung chương
                      TextField(
                        controller: TextEditingController(text: chapters[i].content),
                        decoration: const InputDecoration(labelText: 'Nội dung chương'),
                        onChanged: (value) {
                          chapters[i].content = value; // Cập nhật nội dung chương
                        },
                        maxLines: 3,
                      ),
                      // Cải thiện việc xóa chương
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          setState(() {
                            chapters.removeAt(i); // Xóa chương tại vị trí i
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                TextField(
                  controller: chapterNameController,
                  decoration: const InputDecoration(labelText: 'Tên chương'),
                ),
                TextField(
                  controller: chapterContentController,
                  decoration: const InputDecoration(labelText: 'Nội dung chương'),
                  maxLines: 3,
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      chapters.add(Chapter(
                        name: chapterNameController.text,
                        content: chapterContentController.text,
                      ));
                      chapterNameController.clear();
                      chapterContentController.clear();
                    });
                  },
                  child: const Text('Thêm chương'),
                ),
              ],
            ),
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
                  'Type': selectedType,  // Sử dụng selectedType để lưu giá trị đúng
                  'Chapters': chapters.map((e) => e.toJson()).toList(),
                };

                try {
                  if (book == null) {
                    // Thêm sách mới
                    final newBook = Book(
                      name: updatedData['Name'] as String?,  // Explicitly cast to String?
                      category: updatedData['Category'] as String?,
                      image: updatedData['Image'] as String?,
                      description: updatedData['Description'] as String?,
                      type: updatedData['Type'] as String?,
                      chapters: chapters,
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
