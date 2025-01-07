import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';

final booksSelected = StateProvider<Book>((ref) {
  return Book(name: "Unknown", chapters: []);
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

