
import 'package:book_app/models/chapter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';

final booksSelected = StateProvider<Book>((ref) {
  return Book(name: "Unknown", chapters: []);
});

final chapterSelected = StateProvider<Chapter>((ref) {
  return Chapter(name: "Unknown");
});



