import 'package:firebase_database/firebase_database.dart';
import '../models/book.dart';

class BookController {
  final DatabaseReference _bookRef;

  BookController(FirebaseDatabase database)
      : _bookRef = database.ref().child('Books');

  Future<List<Book>> fetchBooks() async {
    final snapshot = await _bookRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final booksMap = snapshot.value as Map<dynamic, dynamic>;

      return booksMap.values.map((bookData) {
        return Book.fromJson(Map<String, dynamic>.from(bookData));
      }).toList();
    }

    return [];
  }

  Future<List<Book>> fetchRandomBooks(int count) async {

    final snapshot = await _bookRef.get();

    if (!snapshot.exists) {
      return [];
    }

    final books = snapshot.children
        .map((e) => Book.fromJson(Map<String, dynamic>.from(e.value as Map)))
        .toList();

    books.shuffle();
    return books.take(count).toList();
  }

}
