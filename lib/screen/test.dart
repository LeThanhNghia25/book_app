import 'dart:io';
import 'package:book_app/screen/chapter_screen.dart';
import 'package:book_app/screen/read_screen.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/Book.dart';
import 'QRSannerPage.dart';

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
        '/chapters': (context) => ChapterScreen(),
        '/read': (context) => ReadScreen()
      },
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late DatabaseReference _bannerRef, _bookRef;

    final _database = FirebaseDatabase.instanceFor(app: Firebase.app());
    _bannerRef = _database.ref().child('Banners');
    _bookRef = _database.ref().child('Book');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        title: Text('Book App', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, size: 32, color: Colors.white),
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearch(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QRScannerPage()), // Navigate to QR scanner screen
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: getBanners(_bannerRef),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CarouselSlider(
                  items: snapshot.data!
                      .map((url) => Builder(
                    builder: (context) =>
                        Image.network(url, fit: BoxFit.cover),
                  ))
                      .toList(),
                  options: CarouselOptions(
                    autoPlay: true,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    initialPage: 0,
                    height: MediaQuery.of(context).size.height / 3,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Color(0xFFF44A3E),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(
                            'NEW BOOK',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.black,
                      ),
                    )
                  ],
                ),
                FutureBuilder<dynamic>(
                  future: getBook(_bookRef),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Center(child: Text('${snapshot.error}'));
                    } else if (snapshot.hasData) {
                      if (snapshot.data is List<Book>) {
                        List<Book> books = snapshot.data;
                        if (books.isEmpty) {
                          return Center(child: Text("No books available."));
                        }
                        return Expanded(
                          child: GridView.count(
                            crossAxisCount: 2,
                            childAspectRatio: 0.8,
                            padding: const EdgeInsets.all(4.0),
                            mainAxisSpacing: 1.0,
                            crossAxisSpacing: 1.0,
                            children: books.map((book) {
                              return GestureDetector(
                                onTap: () {
                                  ref.read(booksSelected.notifier).state = book;
                                  Navigator.pushNamed(context, "/chapters");
                                },
                                child: Card(
                                  elevation: 12,
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.network(book.image!, fit: BoxFit.cover),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            color: Color(0xAA434343),
                                            padding: const EdgeInsets.all(8),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    book.name ?? "Unknown",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      } else {
                        return Center(child: Text("No books available."));
                      }
                    }
                    return Center(child: CircularProgressIndicator());
                  },
                ),
              ],
            );
          }
          return Center(child: Text('No banners available.'));
        },
      ),
    );
  }

  Future<List<String>> getBanners(DatabaseReference bannerRef) async {
    final snapshot = await bannerRef.get();
    if (snapshot.exists) {
      if (snapshot.value is Map) {
        return (snapshot.value as Map).values.map((e) => e.toString()).toList();
      } else if (snapshot.value is List) {
        return (snapshot.value as List).whereType<String>().toList();
      }
    }
    return [];
  }

  Future<dynamic> getBook(DatabaseReference bookRef) async {
    final snapshot = await bookRef.get();

    if (snapshot.exists && snapshot.value is List) {
      var booksList = snapshot.value as List;
      List<Book> books = [];

      for (var bookData in booksList) {
        books.add(Book.fromJson(Map<String, dynamic>.from(bookData)));
      }
      return books;
    }
    return [];
  }
}

class CustomSearch extends SearchDelegate {
  List<String> allData = [
    'American', 'Italy', 'China', 'Germany', 'France', 'England', 'Vietnamese'
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, size: 27, color: Colors.black, weight: 1.0),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 27, color: Colors.black, weight: 1.0),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in allData) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(
            result,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }
}