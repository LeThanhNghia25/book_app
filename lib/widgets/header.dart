import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Thêm import cho Riverpod
import 'package:book_app/state/state_manager.dart'; // Thêm import của state_manager
import 'package:book_app/controllers/qr_sanner_controller.dart';
import 'package:book_app/screens/chapter_screen.dart';

import '../models/book.dart'; // Thêm import cho ChapterScreen


// Chuyển Header thành ConsumerWidget
class HeaderWithSearch extends ConsumerWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: Color(0xFFF44A3E),
      title: Text('Book App', style: TextStyle(color: Colors.white)),
      actions: [
        IconButton(
          icon: Icon(Icons.search, size: 32, color: Colors.white),
          onPressed: () {
            // Truyền ref vào CustomSearch
            showSearch(
              context: context,
              delegate: CustomSearch(ref: ref), // Truyền ref vào đây
            );
          },
        ),
        IconButton(
          icon: Icon(Icons.qr_code_scanner, color: Colors.white),
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

Future<List<String>> fetchBookNamesFromFirebase() async {
  DatabaseReference bookRef = FirebaseDatabase.instance.ref('Book');
  DataSnapshot snapshot = await bookRef.get();

  if (snapshot.exists && snapshot.value is List) {
    final books = snapshot.value as List;
    return books
        .whereType<Map>()
        .map((book) => book['Name'] as String)
        .toList();
  }
  return [];
}
// Fetch thông tin chi tiết của cuốn sách từ Firebase
Future<Book> fetchBookDetailsFromFirebase(String bookName) async {
  DatabaseReference bookRef = FirebaseDatabase.instance.ref('Book');
  DataSnapshot snapshot = await bookRef.get();

  if (snapshot.exists && snapshot.value is List) {
    var booksList = snapshot.value as List;
    for (var bookData in booksList) {
      var book = Book.fromJson(Map<String, dynamic>.from(bookData));
      if (book.name == bookName) {
        return book;  // Trả về đối tượng Book đầy đủ
      }
    }
  }
  throw Exception("Book not found");
}


class CustomSearch extends SearchDelegate {
  final WidgetRef ref; // Thêm WidgetRef vào constructor
  late Future<List<String>> booksFuture;
  CustomSearch({required this.ref}) {
    booksFuture = fetchBookNamesFromFirebase(); // Tải tên sách từ Firebase
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
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final suggestions = snapshot.data!
              .where((book) => book.toLowerCase().contains(query.toLowerCase()))
              .toList();

          return ListView.builder(
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final bookName = suggestions[index];
              return ListTile(
                title: Text(
                  bookName, style: TextStyle(fontWeight: FontWeight.bold),),
                onTap: () async {
                  // Lấy thông tin chi tiết của cuốn sách từ Firebase dựa trên tên sách
                  Book bookDetails = await fetchBookDetailsFromFirebase(
                      bookName);

                  // Cập nhật thông tin sách vào provider
                  ref
                      .read(booksSelected.notifier)
                      .state = bookDetails;

                  // Điều hướng đến ChapterScreen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChapterScreen(),
                    ),
                  );
                },
              );
            },
          );
        } else {
          return Center(child: Text('No data available.'));
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
