import 'dart:io';
import 'package:book_app/screens/user_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/chapter_screen.dart';
import 'screens/read_screen.dart';
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
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Book App',
      routes: {
        '/': (context) => BaseScreen(child: HomeScreen(), selectedIndex: 0), // Use HomeScreen here
        '/chapters': (context) => BaseScreen(child: ChapterScreen(), selectedIndex: 2),
        '/read': (context) => BaseScreen(child: ReadScreen(), selectedIndex: 1),
        '/user': (context) => BaseScreen(child: UserScreen(), selectedIndex: 3), // Adjusted selectedIndex for user screen
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}
