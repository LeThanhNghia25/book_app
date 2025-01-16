import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/state_manager.dart';
import 'login_screen.dart'; // Đường dẫn đến màn hình đăng nhập

class SavedBooksScreen extends ConsumerWidget {
  const SavedBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(userIdProvider);

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sách đã lưu'),
          backgroundColor: const Color(0xFFF44A3E),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Bạn cần đăng nhập để xem sách đã lưu.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                },
                child: const Text('Đăng nhập'),
              ),
            ],
          ),
        ),
      );
    }

    final savedBooksDetailsAsync = ref.watch(fetchUserSavedBooksDetailsProvider);

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
                title: Text(book.name ?? 'Tên sách không xác định'),
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
