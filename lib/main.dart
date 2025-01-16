import 'dart:io';
import 'package:book_app/screens/admin/admin_screen.dart';
import 'package:book_app/screens/book_details_screen.dart';
import 'package:book_app/screens/chapter_screen.dart';
import 'package:book_app/screens/login_screen.dart';
import 'package:book_app/screens/saved_books_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notifiers/theme_notifier.dart';
import 'base_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'book_app',
    options: FirebaseOptions(
      apiKey: 'AIzaSyCTBPSuR3irO5_e88l1TLTWTiv-W-0BXzc',
      appId: Platform.isIOS || Platform.isMacOS
          ? 'IOS KEY'
          : '1:673807914594:android:ebba6ba9b29e5f35e7e33b',
      messagingSenderId: '673807914594',
      projectId: 'bookapp-c5dce',
      databaseURL: 'https://bookapp-c5dce-default-rtdb.firebaseio.com/',
    ),
  );
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider); // Lấy trạng thái theme từ themeProvider
    return MaterialApp(
      title: 'Book App',
      themeMode: themeMode,
      darkTheme: ThemeData.dark(), // Theme tối
      theme: ThemeData.light(), // Theme sáng
      home: const LoginScreen(),  // Đặt LoginScreen làm màn hình mặc định khi mở ứng dụng
      routes: {
        '/bookDetails': (context) =>  const BookDetails(),
        '/chapters': (context) => const ChapterScreen(),
        '/admin': (context) => const AdminScreen(),
        '/savedArticles': (context) => const SavedBooksScreen(),
        '/login':(context) => const LoginScreen(),
      },
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const Scaffold(
          body: Center(child: Text('Trang không tồn tại!')),
        ),
      ),
    );
  }
}
