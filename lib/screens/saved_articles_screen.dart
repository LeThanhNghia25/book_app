import 'package:book_app/models/book.dart';
import 'package:book_app/controllers/book_save_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_providers.dart';
import '../state/state_manager.dart';
import 'book_details_screen.dart';

// Provider để tải danh sách sách đã lưu
final fetchSavedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookSaveController = ref.read(bookSaveControllerProvider);
  return await bookSaveController.fetchSavedBooks();
});

class SavedArticlesScreen extends ConsumerWidget {
  const SavedArticlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedBooksAsync = ref.watch(fetchSavedBooksProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text(
            'Lưu Sách',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: savedBooksAsync.when(
        data: (savedBooks) {
          if (savedBooks.isEmpty) {
            return const Center(child: Text('Không có sách đã lưu.'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(8),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            itemCount: savedBooks.length,
            itemBuilder: (context, index) {
              final book = savedBooks[index];
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
                  elevation: 8,
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
                          book.name ?? "Không có tiêu đề",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Lỗi: $error')),
      ),
    );
  }
}

