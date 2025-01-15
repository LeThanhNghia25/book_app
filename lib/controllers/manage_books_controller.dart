import 'package:firebase_database/firebase_database.dart';
import '../models/book.dart';

class ManageBooksController {
  final DatabaseReference _bookRef;

  ManageBooksController(FirebaseDatabase database)
      : _bookRef = database.ref('Books');

  // Lấy danh sách tất cả các sách
  Future<List<Book>> fetchAllBooks() async {
    final snapshot = await _bookRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final booksMap = snapshot.value as Map<dynamic, dynamic>;

      // Chuyển đổi dữ liệu từ Firebase sang danh sách Book
      return booksMap.entries.map((entry) {
        final bookId = entry.key.toString();
        final bookData = entry.value as Map<dynamic, dynamic>;
        return Book.fromJson({...bookData, 'id': bookId});
      }).toList();
    } else {
      return [];
    }
  }

  // Xóa sách
  Future<void> deleteBook(String bookId) async {
    await _bookRef.child(bookId).remove();
  }

  // Cập nhật thông tin sách
  Future<void> updateBook(String bookId, Map<String, dynamic> updatedData) async {
    await _bookRef.child(bookId).update(updatedData);
  }

  // Thêm sách mới
  Future<void> addBookAutoId(Book book) async {
    // Lấy tất cả các key hiện tại
    final snapshot = await _bookRef.get();

    String newKey = "book1"; // Giá trị mặc định nếu chưa có sách nào
    if (snapshot.exists && snapshot.value is Map) {
      final booksMap = snapshot.value as Map<dynamic, dynamic>;

      // Tìm id lớn nhất trong các key hiện tại
      final maxId = booksMap.keys
          .where((key) => key.toString().startsWith("book"))
          .map((key) => int.tryParse(key.toString().substring(4)) ?? 0)
          .fold(0, (prev, next) => next > prev ? next : prev);

      // Tạo key mới
      newKey = "book${maxId + 1}";
    }

    // Lưu sách mới với key mới
    await _bookRef.child(newKey).set(book.toJson());
  }
}
