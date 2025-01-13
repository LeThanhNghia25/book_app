import 'package:book_app/models/book.dart';
import 'package:book_app/controllers/book_save_controller.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider giả lập userId (thay bằng logic của bạn)
final userIdProvider = Provider<String>((ref) => 'user4');

// Provider cho BookSaveController
final bookSaveControllerProvider = Provider<BookSaveController>((ref) {
  return BookSaveController(FirebaseDatabase.instance);
});

// Provider lấy danh sách sách đã lưu
final fetchSavedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final userId = ref.watch(userIdProvider);
  final userRef = FirebaseDatabase.instance.ref().child('users').child(userId);
  final snapshot = await userRef.get();

  if (snapshot.exists) {
    final userData = Map<String, dynamic>.from(snapshot.value as Map);
    final savedBookIds = userData['saveBooks']?.split(',') ?? [];
    final bookSaveController = ref.read(bookSaveControllerProvider);

    // Lấy thông tin chi tiết sách từ ID
    return Future.wait(savedBookIds.map((id) async => await bookSaveController.fetchBookById(id)));
  }
  return [];
});

// Provider quản lý trạng thái bookmark của từng cuốn sách
final isBookmarkedProvider = StateProvider.family<bool, String>((ref, bookId) {
  // Đợi cho đến khi dữ liệu sách đã lưu được tải xong
  final savedBooksAsync = ref.watch(fetchSavedBooksProvider);

  return savedBooksAsync.when(
    data: (savedBooks) {
      // Kiểm tra nếu sách đã lưu chứa cuốn sách hiện tại
      return savedBooks.any((book) => book.id == bookId);
    },
    loading: () => false, // Trong khi dữ liệu đang tải, mặc định là false
    error: (error, stack) => false, // Nếu có lỗi, mặc định là false
  );
});
