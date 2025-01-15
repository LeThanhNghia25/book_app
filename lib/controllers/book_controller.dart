import 'package:firebase_database/firebase_database.dart';

import '../models/book.dart';
import '../models/comment.dart';

class BookController {
  final DatabaseReference _bookRef;
  final FirebaseDatabase database;

  BookController(this.database) : _bookRef = database.ref().child('Books');

  // Lấy danh sách sách
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

  // Lấy danh sách sách ngẫu nhiên
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

  Future<List<Comment>> fetchCommentsForBook(String bookId) async {
    final commentRef = database.ref('Comment');
    final snapshot = await commentRef.orderByChild('BookId').equalTo(bookId).get();

    if (snapshot.exists) {
      final commentsMap = snapshot.value as Map<dynamic, dynamic>;
      return commentsMap.entries.map((entry) {
        final commentData = entry.value;
        return Comment.fromMap(commentData);
      }).toList();
    } else {
      return [];
    }
  }
}
