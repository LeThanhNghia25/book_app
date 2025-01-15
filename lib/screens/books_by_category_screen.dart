import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../controllers/book_controller.dart';  // Import controller để lấy dữ liệu
import '../state/state_manager.dart';
import 'book_details_screen.dart';

class BooksByCategoryScreen extends ConsumerWidget {
  final String category;

  const BooksByCategoryScreen({
    required this.category,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookController = BookController(FirebaseDatabase.instance);  // Khởi tạo controller để lấy dữ liệu
    final booksFuture = bookController.fetchBooksByCategory(category);  // Lấy sách theo thể loại

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: booksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Lỗi: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có sách nào trong thể loại này'));
          } else {
            final filteredBooks = snapshot.data!;

            return CustomScrollView(
              slivers: [
                SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final book = filteredBooks[index];
                      return GestureDetector(
                        onTap: () {
                          // Cập nhật selected book vào provider
                          ref.read(selectedBookProvider.notifier).state = book;

                          // Chuyển sang màn hình chi tiết
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const BookDetails(),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 8,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  book.image ?? 'https://i.imgur.com/QsFAQsob.jpg',
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  book.name ?? 'Không có tiêu đề',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: filteredBooks.length,
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}