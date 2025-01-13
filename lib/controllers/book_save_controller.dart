import 'package:firebase_database/firebase_database.dart';
import 'package:book_app/models/book.dart';

class BookSaveController {
  final FirebaseDatabase _database;

  BookSaveController(this._database);

  // Lưu sách vào Firebase Database
  Future<void> saveBook(Book book) async {
    try {
      final bookRef = _database.ref().child('savedBooks').push();  // Tạo ID tự động
      await bookRef.set(book.toMap());  // Lưu book vào Firebase
    } catch (e) {
      print('Error saving book: $e');
      rethrow;
    }
  }

  // Xóa sách khỏi Firebase Database
  Future<void> removeBook(String bookId) async {
    try {
      final ref = _database.ref().child('savedBooks').orderByChild('id').equalTo(bookId);
      final snapshot = await ref.get();

      if (snapshot.exists) {
        snapshot.children.forEach((child) {
          child.ref.remove(); // Xóa sách khỏi Firebase
        });
      } else {
        throw Exception("Sách không tồn tại");
      }
    } catch (e) {
      print('Failed to remove book: $e');
      throw Exception('Failed to remove book: $e');
    }
  }



  // Lấy danh sách sách đã lưu từ Firebase Database
  Future<List<Book>> fetchSavedBooks() async {
    try {
      final snapshot = await _database.ref().child('savedBooks').get();
      if (snapshot.exists) {
        Map<dynamic, dynamic> booksMap = snapshot.value as Map<dynamic, dynamic>;
        return booksMap.values
            .map((bookData) => Book.fromMap(Map<String, dynamic>.from(bookData)))
            .toList();
      }
      return [];
    } catch (e) {
      print('Error fetching saved books: $e');
      rethrow;
    }
  }
}
