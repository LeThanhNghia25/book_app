import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../state/state_manager.dart';

class SavedBooksScreen extends ConsumerWidget {
  final String userId; // Nhận userId từ UserScreen

  const SavedBooksScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedBooksDetailsAsync =
    ref.watch(fetchUserSavedBooksDetailsProvider(userId)); // Lấy sách đã lưu

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sách đã lưu'),
        backgroundColor: const Color(0xFFF44A3E),
      ),
      body: savedBooksDetailsAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return const Center(child: Text('Không có sách đã lưu.'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: Image.network(
                  book.image ?? 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(book.name ?? 'Tên sách không xác định'),
                subtitle: Text(book.category ?? 'Không có danh mục'),
                onTap: () {
                  ref.read(selectedBookProvider.notifier).state = book;
                  Navigator.pushNamed(context, '/bookDetails');
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
