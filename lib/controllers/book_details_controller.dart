import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/book.dart';
import '../state/state_manager.dart';  // Import state_manager.dart để dùng selectedBookProvider

// Controller quản lý book details
class BookDetailsController {
  final WidgetRef ref;

  BookDetailsController(this.ref);

  // Cập nhật cuốn sách được chọn
  void selectBook(Book book) {
    ref.read(selectedBookProvider.notifier).state = book;
  }

  // Lấy cuốn sách hiện tại đang được chọn
  Book? get selectedBook => ref.read(selectedBookProvider);
}
