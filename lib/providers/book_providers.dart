import 'package:book_app/models/book.dart';
import 'package:book_app/controllers/book_save_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider lấy userId từ Firebase Authentication
final userIdProvider = Provider<String>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    return user.uid; // Lấy userId từ Firebase
  } else {
    throw Exception('User not logged in'); // Xử lý nếu người dùng chưa đăng nhập
  }
});

// Provider cho BookSaveController
final bookSaveControllerProvider = Provider<BookSaveController>((ref) {
  return BookSaveController(FirebaseDatabase.instance);
});

// Provider lấy danh sách sách đã lưu
final fetchSavedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final userId = ref.watch(userIdProvider); // Lấy userId từ Provider
  final savedBooksRef = FirebaseDatabase.instance.ref('saved_books');

  // Lấy danh sách sách đã lưu cho user hiện tại
  final snapshot = await savedBooksRef.orderByChild('userId').equalTo(userId).get();

  if (snapshot.exists) {
    final savedBooks = <Book>[];
    final bookSaveController = ref.read(bookSaveControllerProvider);

    for (var child in snapshot.children) {
      final bookId = child.child('bookId').value as String;

      // Lấy thông tin chi tiết sách từ ID
      final book = await bookSaveController.fetchBookById(bookId);
      savedBooks.add(book);
    }
    return savedBooks;
  }
  return [];
});

// Provider quản lý trạng thái bookmark của từng cuốn sách
final isBookmarkedProvider = StateProvider.family<bool, String>((ref, bookId) {
  final savedBooksAsync = ref.watch(fetchSavedBooksProvider);

  return savedBooksAsync.when(
    data: (savedBooks) {
      // Kiểm tra xem danh sách sách đã lưu có chứa bookId không
      return savedBooks.any((book) => book.id == bookId);
    },
    loading: () => false, // Trong khi dữ liệu đang tải, mặc định là false
    error: (error, stack) => false, // Nếu có lỗi, mặc định là false
  );
});
