
import 'package:book_app/model/Chapters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/Book.dart';

final booksSelected = StateProvider<Book>((ref) {
  return Book(name: "Unknown", chapters: []);
});

final chapterSelected = StateProvider<Chapters>((ref) {
  return Chapters(name: "Unknown");
});



