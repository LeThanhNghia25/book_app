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
}
