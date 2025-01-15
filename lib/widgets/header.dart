import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:book_app/controllers/qr_sanner_controller.dart';
import 'package:book_app/screens/chapter_screen.dart';
import '../models/book.dart';
import 'package:diacritic/diacritic.dart';

class HeaderWithSearch extends ConsumerWidget implements PreferredSizeWidget {
  const HeaderWithSearch({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: const Color(0xFFF44A3E),
      title: const Text(
        'Book App',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, size: 32, color: Colors.white),
          onPressed: () {
            showSearch(
              context: context,
              delegate: CustomSearch(ref: ref),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.qr_code_scanner, size: 32, color: Colors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => QRScannerPage()),
            );
          },
        ),
      ],
    );
  }
}

// Lấy danh sách tên sách từ Firebase (theo dạng Map)
Future<List<String>> fetchBookNamesFromFirebase() async {
  DatabaseReference bookRef = FirebaseDatabase.instance.ref('Books');
  DataSnapshot snapshot = await bookRef.get();

  if (snapshot.exists && snapshot.value is Map) {
    final booksMap = snapshot.value as Map<dynamic, dynamic>;
    return booksMap.entries
        .map((entry) => entry.value['Name'] as String)
        .toList();
  }
  return [];
}

// Fetch thông tin chi tiết của cuốn sách theo tên
Future<Book> fetchBookDetailsFromFirebase(String bookName) async {
  DatabaseReference bookRef = FirebaseDatabase.instance.ref('Books');
  DataSnapshot snapshot = await bookRef.get();

  if (snapshot.exists && snapshot.value is Map) {
    final booksMap = snapshot.value as Map<dynamic, dynamic>;

    for (var entry in booksMap.entries) {
      final bookId = entry.key.toString(); // Lấy ID từ Firebase
      final bookData = Map<String, dynamic>.from(entry.value);
      final book = Book.fromJson(bookData, bookId); // Truyền ID vào fromJson
      if (book.name == bookName) {
        return book; // Trả về Book khi tìm thấy
      }
    }
  }
  throw Exception("Book not found");
}

class CustomSearch extends SearchDelegate {
  final WidgetRef ref;
  late Future<List<String>> booksFuture;

  CustomSearch({required this.ref}) {
    booksFuture = fetchBookNamesFromFirebase();
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, size: 27, color: Colors.black),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 27, color: Colors.black),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: booksFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          // Loại bỏ dấu (diacritics) trước khi so sánh
          final normalizedQuery = removeDiacritics(query.toLowerCase());

          final suggestions = snapshot.data!
              .where((book) =>
              removeDiacritics(book.toLowerCase()).contains(normalizedQuery))
              .toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final bookName = suggestions[index];
              return ListTile(
                title: Text(
                  bookName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () async {
                  try {
                    Book bookDetails = await fetchBookDetailsFromFirebase(bookName);
                    ref.read(selectedBookProvider.notifier).state = bookDetails;

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChapterScreen(),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không tìm thấy sách!')),
                    );
                  }
                },
              );
            },
          );
        } else {
          return const Center(child: Text('Không có dữ liệu.'));
        }
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text('Bạn đã chọn: $query'),
    );
  }
}