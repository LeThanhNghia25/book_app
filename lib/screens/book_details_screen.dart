import 'package:book_app/models/book.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/book_save_controller.dart';
import '../providers/book_providers.dart';

// Provider để lưu trạng thái đã lưu bài viết
final isBookmarkedProvider = StateProvider<bool>((ref) => false);

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider); // Lấy dữ liệu sách từ provider

    if (book == null) {
      return Scaffold(
        body: Center(
          child: Text('Không tìm thấy thông tin sách!'),
        ),
      );
    }

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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Image.network(
                    book.image ?? 'https://via.placeholder.com/100',
                    height: 220,
                    width: 200,
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
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          book.category ?? "Không có danh mục",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
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
                                "Đọc ngay",
                                style: TextStyle(color: Color(0xFFF44A3E)),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              onPressed: () async {
                                final isBookmarked = ref.read(isBookmarkedProvider.notifier);
                                final book = ref.read(selectedBookProvider);

                                if (book == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Sách không tồn tại")),
                                  );
                                  return;
                                }

                                isBookmarked.state = !isBookmarked.state;

                                final bookSaveController = ref.read(bookSaveControllerProvider);

                                if (isBookmarked.state) {
                                  try {
                                    await bookSaveController.saveBook(book);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Đã lưu sách")),
                                    );
                                    ref.refresh(fetchSavedBooksProvider); // Làm mới danh sách đã lưu sau khi lưu
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Lỗi khi lưu sách: $e")),
                                    );
                                  }
                                } else {
                                  try {
                                    await bookSaveController.removeBook(book.id!);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("Đã hủy lưu sách")),
                                    );
                                    ref.refresh(fetchSavedBooksProvider); // Làm mới danh sách đã lưu sau khi hủy lưu
                                  } catch (e) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text("Lỗi khi hủy lưu sách: $e")),
                                    );
                                  }
                                }
                              }
                              ,
                              icon: Icon(
                                ref.watch(isBookmarkedProvider)
                                    ? Icons.bookmark
                                    : Icons.bookmark_border,
                                color: ref.watch(isBookmarkedProvider)
                                    ? Colors.yellow
                                    : Colors.grey,
                              ),
                              iconSize: 30,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Giới thiệu",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Đây là phần mô tả về cuốn sách. Bạn có thể thay đổi dữ liệu từ controller.",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                "Có thể bạn quan tâm",
                style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
