import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/book_controller.dart';
import '../controllers/book_saved_controller.dart';
import '../controllers/user_controller.dart';
import '../models/book.dart';
import '../models/saved_books.dart';

// Quản lý trạng thái sách được chọn
final selectedBookProvider = StateProvider<Book?>((ref) => null);
final userControllerProvider = Provider((ref) {
  return UserController(FirebaseDatabase.instance);
});

final bookControllerProvider = Provider((ref) {
  return BookController(FirebaseDatabase.instance);
});

final chapterSelected = StateProvider<Chapter>((ref) {
  return Chapter(name: "Unknown");
});

// Tạo provider cho FirebaseDatabase
final firebaseDatabaseProvider = Provider<FirebaseDatabase>((ref) {
  return FirebaseDatabase.instanceFor(
    app: Firebase.app(),
    databaseURL: 'https://bookapp-c5dce-default-rtdb.firebaseio.com/',
  );
});
// Provider cho Firebase Auth để lấy người dùng hiện tại
final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

// Provider lấy userId của người dùng hiện tại
final userIdProvider = Provider<String?>((ref) {
  final user = ref.watch(firebaseAuthProvider).currentUser;
  return user?.uid; // Trả về UID nếu người dùng đang đăng nhập, ngược lại trả về null
});

// Provider cho BookSaveController
final bookSaveControllerProvider = Provider<BookSaveController>((ref) {
  return BookSaveController(FirebaseDatabase.instance);
});

// Provider lấy danh sách sách đã lưu
final fetchUserSavedBooksProvider = FutureProvider<List<String>>((ref) async {
  final userId = ref.watch(userIdProvider);

  // Kiểm tra nếu `userId` là null (người dùng chưa đăng nhập)
  if (userId == null) {
    return [];
  }

  final bookSaveController = ref.read(bookSaveControllerProvider);

  return await bookSaveController.fetchSavedBooks(userId);
});

// Lấy chi tiết danh sách các sách đã lưu
final fetchUserSavedBooksDetailsProvider =
FutureProvider.family<List<Book>, String>((ref, userId) async {
  final database = FirebaseDatabase.instance;

  // Lấy danh sách bookId từ saved_books
  final savedBooksRef = database.ref('saved_books/$userId');
  final snapshot = await savedBooksRef.get();

  if (!snapshot.exists || snapshot.value == null) {
    return []; // Trả về danh sách rỗng nếu không có sách đã lưu
  }

  final bookIds = List<String>.from(snapshot.value as List);

  // Lấy thông tin chi tiết từng sách từ bảng Books
  final books = await Future.wait(
    bookIds.map((bookId) async {
      final bookSnapshot = await database.ref('Books/$bookId').get();
      if (bookSnapshot.exists) {
        return Book.fromJson(
          Map<String, dynamic>.from(bookSnapshot.value as Map),
          bookId,
        );
      } else {
        return Book(
          id: bookId,
          name: 'Sách không tìm thấy',
          image: 'https://via.placeholder.com/150',
        );
      }
    }),
  );

  return books;
});


// Provider quản lý trạng thái bookmark của từng cuốn sách
final isBookmarkedProvider = StateProvider.family<bool, String>((ref, bookId) {
  // Đợi cho đến khi dữ liệu sách đã lưu được tải xong
  final savedBooksDetailsAsync = ref.watch(fetchUserSavedBooksProvider);

  return savedBooksDetailsAsync.when(
    data: (savedBooksIds) {
      // Kiểm tra nếu bookId có trong danh sách savedBooksIds
      return savedBooksIds.contains(bookId);
    },
    loading: () => false, // Trong khi dữ liệu đang tải, mặc định là false
    error: (error, stack) => false, // Nếu có lỗi, mặc định là false
  );
});