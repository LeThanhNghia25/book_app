import 'dart:io';
import 'package:book_app/screens/bookDetails_screen.dart';
import 'package:book_app/screens/chapter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      home: const BaseScreen(),
      routes: {
        '/bookDetails': (context) => BookDetails(),
      },
    );
  }

}
