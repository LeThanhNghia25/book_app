import 'package:book_app/controllers/book_controller.dart';
import 'package:book_app/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/state_manager.dart';

class AllBooksScreen extends ConsumerWidget {
  const AllBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy instance của FirebaseDatabase thông qua provider
    final firebaseDatabase = ref.read(firebaseDatabaseProvider);
    final bookController = BookController(firebaseDatabase);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),  // Đổi màu icon về trắng
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text(
            "All Books",
            style: TextStyle(color: Colors.white), // Đảm bảo chữ có màu trắng
          ),
        ),
      ),
      body: FutureBuilder<List<Book>>(
        future: bookController.fetchBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            final books = snapshot.data!;
            return GridView.builder(
              padding: const EdgeInsets.all(8.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.7,
              ),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedBookProvider.notifier).state = book;
                    Navigator.pushNamed(context, "/chapters");
                  },
                  child: Card(
                    elevation: 8,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            book.image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            book.name!,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No books available."));
          }
        },
      ),
    );
  }
}
