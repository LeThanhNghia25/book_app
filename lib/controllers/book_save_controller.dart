import 'package:book_app/models/book.dart';
import 'package:firebase_database/firebase_database.dart';

class BookSaveController {
  final FirebaseDatabase _database;

  BookSaveController(this._database);

  // Lưu sách vào danh sách đã lưu của người dùng
  Future<void> saveBook(Book book, String userId) async {
    try {
      final userRef = _database.ref().child('users').child(userId);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final currentData = Map<String, dynamic>.from(snapshot.value as Map);
        final savedBooks = currentData['saveBooks']?.split(',') ?? [];
        if (!savedBooks.contains(book.id)) {
          savedBooks.add(book.id!);
          await userRef.update({'saveBooks': savedBooks.join(',')});
        }
      }
    } catch (e) {
      print('Error saving book: $e');
      rethrow;
    }
  }

  // Xóa sách khỏi danh sách đã lưu
  Future<void> removeBook(String bookId, String userId) async {
    try {
      final userRef = _database.ref().child('users').child(userId);
      final snapshot = await userRef.get();
      if (snapshot.exists) {
        final currentData = Map<String, dynamic>.from(snapshot.value as Map);
        final savedBooks = currentData['saveBooks']?.split(',') ?? [];
        if (savedBooks.contains(bookId)) {
          savedBooks.remove(bookId);
          await userRef.update({'saveBooks': savedBooks.join(',')});
        }
      }
    } catch (e) {
      print('Error removing book: $e');
      rethrow;
    }
  }

  // Lấy thông tin sách từ ID
  Future<Book> fetchBookById(String bookId) async {
    try {
      final bookRef = _database.ref().child('books').child(bookId);
      final snapshot = await bookRef.get();
      if (snapshot.exists) {
        return Book.fromJson(
          Map<String, dynamic>.from(snapshot.value as Map),
          bookId, // Truyền ID của sách vào đây
        );
      } else {
        throw Exception('Book not found');
      }
    } catch (e) {
      print('Error fetching book: $e');
      rethrow;
    }
  }

}
