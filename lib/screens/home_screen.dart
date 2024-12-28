import 'package:book_app/controllers/banner_controller.dart';
import 'package:book_app/controllers/book_controller.dart';
import 'package:book_app/models/book.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/state_manager.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = FirebaseDatabase.instanceFor(app: Firebase.app());
    final bannerController = BannerController(database);
    final bookController = BookController(database);

    return Scaffold(
      body: Column(
        children: [
          // Banner Section
          FutureBuilder<List<String>>(
            future: bannerController.fetchBanners(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return CarouselSlider(
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
                );
              } else {
                return const Center(child: Text('No banners available.'));
              }
            },
          ),

          // Books Section
          Expanded(
            child: FutureBuilder<List<Book>>(
              future: bookController.fetchBooks(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  // Lọc sách bị null
                  final books = snapshot.data!
                      .where((book) => book.name != null)
                      .toList();

                  return GridView.count(
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
                                    color: const Color(0xAA434343),
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            book.name ?? "Unknown",
                                            style: const TextStyle(
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
                  );
                } else {
                  return const Center(child: Text('No books available.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}