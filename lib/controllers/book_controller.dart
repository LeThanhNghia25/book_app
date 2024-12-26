import 'package:firebase_database/firebase_database.dart';
import '../models/book.dart';

class BookController {
  final DatabaseReference _bookRef;

  BookController(FirebaseDatabase database)
      : _bookRef = database.ref().child('Book');

  Future<List<Book>> fetchBooks() async {
    final snapshot = await _bookRef.get();
    if (snapshot.exists && snapshot.value is List) {
      var booksList = snapshot.value as List;
      return booksList.map((bookData) {
        return Book.fromJson(Map<String, dynamic>.from(bookData));
      }).toList();
    }
    return [];
  }
}
