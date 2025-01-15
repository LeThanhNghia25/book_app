import 'package:book_app/models/saved_book.dart'; // Import model SavedBook
import 'package:book_app/models/book.dart'; // Import model Book
import 'package:firebase_database/firebase_database.dart';

class BookSaveController {
  final FirebaseDatabase _database;

  BookSaveController(this._database);

  // Lưu sách vào danh sách đã lưu của người dùng
  Future<void> saveBook(Book book, String userId) async {
    try {
      // Tạo một ID mới cho mỗi sách được lưu
      final savedBooksRef = _database.ref('saved_books').push();
      final sbId = savedBooksRef.key!;

      // Tạo đối tượng SavedBook
      final savedBook = SavedBooks(
        sbId: sbId,
        bookId: book.id!,
        userId: userId,
      );

      // Lưu đối tượng SavedBook vào Firebase
      await savedBooksRef.set(savedBook.toMap());
    } catch (e) {
      print('Error saving book: $e');
      rethrow;
    }
  }

  // Xóa sách khỏi danh sách đã lưu của người dùng
  Future<void> removeBook(String bookId, String userId) async {
    try {
      // Lấy tham chiếu tới node 'saved_books'
      final savedBooksRef = _database.ref('saved_books');

      // Lọc sách đã lưu theo userId và bookId
      final snapshot = await savedBooksRef
          .orderByChild('userId')
          .equalTo(userId)
          .get();

      for (var child in snapshot.children) {
        if (child.child('bookId').value == bookId) {
          await child.ref.remove(); // Xóa sách đã lưu
          break;
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
        return Book.fromJson(Map<String, dynamic>.from(snapshot.value as Map));
      } else {
        throw Exception('Book not found');
      }
    } catch (e) {
      print('Error fetching book: $e');
      rethrow;
    }
  }
}
