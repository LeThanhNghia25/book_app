import 'package:book_app/models/book.dart';
import 'package:book_app/screens/chapter_screen.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/book_controller.dart';
import '../controllers/book_save_controller.dart';
import '../state/state_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);
    if (book == null) {
      return Scaffold(
        body: const Center(child: Text('Không tìm thấy thông tin sách!')),
      );
    }
    final savedBooksAsync = ref.watch(fetchSavedBooksProvider); // Lấy danh sách sách đã lưu
    final database = FirebaseDatabase.instance;
    final bookController = BookController(database);
    if (book == null) {
      return const Scaffold(
        body: Center(child: Text('Không tìm thấy thông tin sách!')),
      );
    }

    return savedBooksAsync.when(
      data: (savedBooks) {
        // Kiểm tra xem cuốn sách hiện tại có trong danh sách đã lưu không
        final isBookmarked = savedBooks.contains(book.id);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF44A3E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              book.name ?? 'Chi Tiết Sách',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị thông tin sách
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh bìa sách với kích thước cố định
                      Container(
                        height: 260,
                        width: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: NetworkImage(
                              book.image ?? 'https://i.imgur.com/QsFAQsob.jpg',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Phần thông tin sách
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.name ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2, // Cố định số dòng tối đa
                              overflow: TextOverflow.ellipsis, // Hiển thị "..." nếu quá dài
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.category ?? 'Không có danh mục',
                              style: const TextStyle(fontSize: 18),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            // Nút hành động
                            Wrap(
                              spacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(selectedBookProvider.notifier).state = book;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const ChapterScreen(),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(color: Color(0xFFF44A3E)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Đọc ngay',
                                    style: TextStyle(color: Color(0xFFF44A3E)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final bookSaveController = BookSaveController(FirebaseDatabase.instance);
                                    final user = FirebaseAuth.instance.currentUser;

                                    if (user == null) {
                                      print('Error: User not logged in');
                                      return;
                                    }

                                    final userId = user.uid;

                                    try {
                                      if (isBookmarked) {
                                        await bookSaveController.removeBook(book.id!, userId);
                                      } else {
                                        await bookSaveController.saveBook(book, userId);
                                      }
                                    } catch (e) {
                                      print('Error updating bookmark: $e');
                                    }
                                  },
                                  icon: Icon(
                                    isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                                    color: isBookmarked ? Colors.yellow : Colors.grey,
                                  ),
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Phần giới thiệu
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giới thiệu',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Phần description có thể thu gọn
                      DescriptionWithToggle(description: book.description),
                    ],
                  ),
                ),
                const Divider(),
                // Có thể bạn quan tâm
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Có thể bạn quan tâm',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Book>>(
                  future: bookController.fetchRandomBooks(6),  // Lấy 6 sách ngẫu nhiên
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('Không có sách nào được đề xuất.'));
                    } else {
                      final books = snapshot.data!;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedBookProvider.notifier).state = book;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookDetails(),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
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
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      // Khi dữ liệu đang tải
      error: (error, stack) =>
          Center(child: Text('Lỗi: $error')), // Nếu có lỗi khi lấy dữ liệu
    );
  }
}

// Widget để hiển thị phần description có thể thu gọn
class DescriptionWithToggle extends StatefulWidget {
  final String? description;

  const DescriptionWithToggle({Key? key, this.description}) : super(key: key);

  @override
  _DescriptionWithToggleState createState() => _DescriptionWithToggleState();
}

class _DescriptionWithToggleState extends State<DescriptionWithToggle> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String displayText = widget.description ?? 'Không có mô tả';
    // Hiển thị 100 ký tự đầu tiên nếu mô tả dài
    if (!isExpanded && displayText.length > 100) {
      displayText = '${displayText.substring(0, 100)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: const TextStyle(fontSize: 17),
        ),
        if ((widget.description?.length ?? 0) > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  isExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: TextStyle(
                      color: const Color(0xFFF44A3E),
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                  color: const Color(0xFFF44A3E),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

