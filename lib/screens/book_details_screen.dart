import 'package:book_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider);  // Lấy dữ liệu sách từ provider

    if (book == null) {
      return const Scaffold(
        body: Center(
          child: Text('Không tìm thấy thông tin sách!'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
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
            // Header section with book cover and title
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.network(
                    book.image ?? 'https://via.placeholder.com/100',  // Hiển thị bìa sách
                    height: 120,
                    width: 100,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.name ?? "Không có tiêu đề",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(book.category ?? "Không có danh mục"),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Điều hướng đến màn hình Chapter
                                ref.read(booksSelected.notifier).state = book;
                                Navigator.pushNamed(context, "/chapters");
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,  // Đổi màu nền
                                side: const BorderSide(color: Colors.purple), // Viền tím
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                "Đọc ngay",
                                style: TextStyle(color: Colors.purple),  // Đổi màu chữ sang tím
                              ),
                            ),
                            const SizedBox(width: 16),
                            IconButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Đã lưu bài viết")),
                                );
                              },
                              icon: const Icon(Icons.bookmark_border),
                              color: Colors.grey,
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
            // Description section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Giới thiệu",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Đây là phần mô tả về cuốn sách. Bạn có thể thay đổi dữ liệu từ controller.",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
