import 'package:book_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../state/state_manager.dart';

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider); // Lấy sách hiện tại
    final savedBooksAsync = ref.watch(fetchSavedBooksProvider); // Lấy danh sách sách đã lưu

    if (book == null) {
      return Scaffold(
        body: const Center(child: Text('Không tìm thấy thông tin sách!')),
      );
    }

    return savedBooksAsync.when(
      data: (savedBooks) {
        // Kiểm tra xem cuốn sách hiện tại có trong danh sách đã lưu không
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
                        book.image ?? 'https://via.placeholder.com/100',
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
                                fontSize: 24,
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
                                        // Nếu sách đã được lưu, hủy lưu
                                        await bookSaveController.removeBook(book.id!, ref.read(userIdProvider));
                                        // Cập nhật trạng thái cho sách hiện tại
                                        ref.read(isBookmarkedProvider(book.id!).notifier).state = false;
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Đã hủy lưu sách: ${book.name}')),
                                        );
                                      } else {
                                        // Nếu sách chưa được lưu, lưu lại
                                        await bookSaveController.saveBook(book, ref.read(userIdProvider));
                                        // Cập nhật trạng thái cho sách hiện tại
                                        ref.read(isBookmarkedProvider(book.id!).notifier).state = true;
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
                      // Text(
                      //   book.description ?? 'Không có mô tả',
                      //   style: const TextStyle(fontSize: 17),
                      // ),
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
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()), // Khi dữ liệu đang tải
      error: (error, stack) => Center(child: Text('Lỗi: $error')), // Nếu có lỗi khi lấy dữ liệu
    );
  }
}
