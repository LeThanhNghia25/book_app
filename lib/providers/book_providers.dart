import 'package:book_app/controllers/book_save_controller.dart';
import 'package:book_app/models/book.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Khai báo BookSaveController provider
final bookSaveControllerProvider = Provider<BookSaveController>((ref) {
  return BookSaveController(FirebaseDatabase.instance);
});

// Provider lấy danh sách sách đã lưu
final fetchSavedBooksProvider = FutureProvider<List<Book>>((ref) async {
  final bookSaveController = ref.read(bookSaveControllerProvider);
  return await bookSaveController.fetchSavedBooks();
});