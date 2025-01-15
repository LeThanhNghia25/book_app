import 'package:firebase_database/firebase_database.dart';
import '../models/book.dart';
import '../models/comment.dart';

class BookController {
  final DatabaseReference _bookRef;


  BookController(FirebaseDatabase database)
      : _bookRef = database.ref().child('Books');

  Future<List<Book>> fetchBooks() async {
    final snapshot = await _bookRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final booksMap = snapshot.value as Map<dynamic, dynamic>;

      return booksMap.entries.map((entry) {
        final id = entry.key as String; // Lấy id từ key Firebase
        final bookData = entry.value as Map<dynamic, dynamic>;
        return Book.fromJson(Map<String, dynamic>.from(bookData), id);
      }).toList();
    }

    return [];
  }

  Future<List<Book>> fetchRandomBooks(int count) async {
    final snapshot = await _bookRef.get();
    if (!snapshot.exists) {
      return [];
    }

    final books = snapshot.children.map((e) {
      final id = e.key as String; // Lấy id từ key Firebase
      final bookData = e.value as Map<dynamic, dynamic>;
      return Book.fromJson(Map<String, dynamic>.from(bookData), id);
    }).toList();

    books.shuffle();
    return books.take(count).toList();
  }


  // Phương thức lấy sách theo thể loại
  Future<List<Book>> fetchBooksByCategory(String category) async {
    final snapshot = await _bookRef.get();
    if (!snapshot.exists) {
      return [];
    }

    final books = snapshot.children.map((e) {
      final id = e.key as String; // Lấy id từ key Firebase
      final bookData = e.value as Map<dynamic, dynamic>;
      return Book.fromJson(Map<String, dynamic>.from(bookData), id);
    }).toList();

    // Lọc sách theo thể loại
    return books.where((book) {
      final bookCategories = (book.category ?? '')
          .split(',')
          .map((cat) => cat.trim().toLowerCase())
          .toList();
      return bookCategories.contains(category.trim().toLowerCase());
    }).toList();
  }

}
