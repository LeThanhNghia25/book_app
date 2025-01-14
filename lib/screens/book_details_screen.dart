import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/book.dart';
import '../controllers/book_controller.dart';
import '../providers/book_providers.dart';
import '../state/state_manager.dart';

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider); // Sách hiện tại
    final savedBooksAsync = ref.watch(fetchSavedBooksProvider); // Danh sách sách đã lưu
    final database = FirebaseDatabase.instance;
    final bookController = BookController(database); // Đối tượng điều khiển sách

    if (book == null) {
      return Scaffold(
        body: const Center(child: Text('Không tìm thấy thông tin sách!')),
      );
    }

    return savedBooksAsync.when(
      data: (savedBooks) {
        // Kiểm tra xem sách đã được lưu hay chưa
        final isBookmarked = savedBooks.any((savedBook) => savedBook.id == book.id);

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
                    children: [
                      Image.network(
                        book.image ?? 'https://via.placeholder.com/150',
                        height: 280,
                        width: 200,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.name ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.category ?? 'Không có danh mục',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    ref.read(booksSelected.notifier).state = book;
                                    Navigator.pushNamed(context, "/chapters");
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
                                const SizedBox(width: 10),
                                IconButton(
                                  onPressed: () async {
                                    final bookSaveController = ref.read(bookSaveControllerProvider);
                                    try {
                                      if (isBookmarked) {
                                        await bookSaveController.removeBook(book.id!, ref.read(userIdProvider));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Đã hủy lưu sách: ${book.name}')),
                                        );
                                      } else {
                                        await bookSaveController.saveBook(book, ref.read(userIdProvider));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Đã lưu sách: ${book.name}')),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Lỗi khi lưu sách: $e')),
                                      );
                                    }

                                    ref.refresh(fetchSavedBooksProvider); // Làm mới danh sách sách đã lưu
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
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Phần description có thể thu gọn
                      DescriptionWithToggle(description: book.description),
                    ],
                  ),
                ),
                const Divider(),
                // Phần bạn có thể quan tâm
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Có thể bạn quan tâm',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Book>>(
                  future: bookController.fetchRandomBooks(6), // Lấy 6 sách ngẫu nhiên
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
                                      book.image ?? 'https://via.placeholder.com/150',
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
      error: (error, stack) => Center(child: Text('Lỗi: $error')),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isExpanded
              ? widget.description ?? 'Không có mô tả'
              : (widget.description?.length ?? 0) > 100
              ? '${widget.description?.substring(0, 100)}...'
              : widget.description ?? 'Không có mô tả',
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
                  style: TextStyle(color: const Color(0xFFF44A3E), fontWeight: FontWeight.bold),
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
