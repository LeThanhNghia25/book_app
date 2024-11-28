
import 'package:book_app/model/Chapters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/Book.dart';

final booksSelected = StateProvider((ref) => Book());
final chapterSelected = StateProvider((ref) => Chapters());


