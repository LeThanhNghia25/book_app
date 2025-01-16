import 'package:book_app/models/saved_books.dart';
import 'package:book_app/models/book.dart';
import 'package:firebase_database/firebase_database.dart';

class BookSaveController {
  final FirebaseDatabase _database;

  BookSaveController(this._database);

  // Lưu sách vào danh sách đã lưu
  Future<void> saveBook(String bookId, String userId) async {
    final dbRef = _database.ref("saved_books/$userId");
    final snapshot = await dbRef.get();

    List<String> savedBooks = [];
    if (snapshot.exists) {
      savedBooks = List<String>.from(snapshot.value as List);
    }

    if (!savedBooks.contains(bookId)) {
      savedBooks.add(bookId);
      await dbRef.set(savedBooks); // Lưu danh sách mới
    }
  }

  // Xóa sách khỏi danh sách đã lưu
  Future<void> removeBook(String bookId, String userId) async {
    final dbRef = _database.ref("saved_books/$userId");
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      List<String> savedBooks = List<String>.from(snapshot.value as List);
      savedBooks.remove(bookId);
      await dbRef.set(savedBooks); // Cập nhật danh sách sau khi xóa
    }
  }

  // Lấy danh sách sách đã lưu của người dùng
  Future<List<String>> fetchSavedBooks(String userId) async {
    final dbRef = _database.ref("saved_books/$userId");
    final snapshot = await dbRef.get();

    if (snapshot.exists) {
      return List<String>.from(snapshot.value as List);
    }
    return [];
  }

  // Lấy thông tin sách từ ID
  Future<Book> fetchBookById(String bookId) async {
    final bookRef = _database.ref('books').child(bookId);
    final snapshot = await bookRef.get();
    if (snapshot.exists) {
      return Book.fromJson(
        Map<String, dynamic>.from(snapshot.value as Map),
        bookId,
      );
    }
    throw Exception('Book not found');
  }

  // Lấy danh sách đối tượng Book đã lưu của người dùng
  Future<List<Book>> fetchSavedBooksDetails(String userId) async {
    final savedBooks = await fetchSavedBooks(userId);
    return Future.wait(savedBooks.map((bookId) => fetchBookById(bookId)));
  }
}
