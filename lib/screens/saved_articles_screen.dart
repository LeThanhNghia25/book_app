  import 'package:book_app/models/book.dart';
  import 'package:book_app/screens/book_details_screen.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import '../providers/book_providers.dart';
  import '../state/state_manager.dart';

  class SavedArticlesScreen extends ConsumerWidget {
    const SavedArticlesScreen({super.key});

    @override
    Widget build(BuildContext context, WidgetRef ref) {
      final savedBooksAsync = ref.watch(fetchSavedBooksProvider);

      return Scaffold(
        appBar: AppBar(
          title: const Text('Sách đã lưu'),
          backgroundColor: const Color(0xFFF44A3E),
        ),
        body: savedBooksAsync.when(
          data: (savedBooks) {
            if (savedBooks.isEmpty) {
              return const Center(child: Text('Không có sách đã lưu.'));
            }

            return ListView.builder(
              itemCount: savedBooks.length,
              itemBuilder: (context, index) {
                final book = savedBooks[index];

                // Sử dụng `StateProvider` cho trạng thái bookmark của từng cuốn sách
                final isBookmarked = ref.watch(isBookmarkedProvider(book.id!));

                return ListTile(
                  title: Text(book.name ?? 'Không có tiêu đề'),
                  subtitle: Text(book.category ?? 'Không có danh mục'),
                  trailing: IconButton(
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: isBookmarked ? Colors.yellow : Colors.grey,
                    ),
                    onPressed: () async {
                      final bookSaveController = ref.read(bookSaveControllerProvider);
                      try {
                        if (isBookmarked) {
                          // Nếu sách đã được lưu, hủy lưu
                          await bookSaveController.removeBook(book.id!, ref.read(userIdProvider));
                          ref.read(isBookmarkedProvider(book.id!).notifier).state = false;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Đã hủy lưu sách: ${book.name}')),
                          );
                        } else {
                          // Nếu sách chưa được lưu, lưu lại
                          await bookSaveController.saveBook(book, ref.read(userIdProvider));
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
                  ),
                  onTap: () {
                    ref.read(selectedBookProvider.notifier).state = book;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const BookDetails()),
                    );
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Lỗi: $error')),
        ),
      );
    }
  }
