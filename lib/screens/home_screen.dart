import 'package:book_app/controllers/banner_controller.dart';
import 'package:book_app/controllers/book_controller.dart';
import 'package:book_app/models/book.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/google_books_api.dart';
import '../state/state_manager.dart';
import 'all_books_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final database = FirebaseDatabase.instanceFor(app: Firebase.app());
    final bannerController = BannerController(database);
    final bookController = BookController(database);
    final googleBooksAPI = GoogleBooksAPI();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Banner Section
          SliverToBoxAdapter(
            child: FutureBuilder<List<String>>(
              future: bannerController.fetchBanners(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No banners available.'));
                } else {
                  return CarouselSlider(
                    items: snapshot.data!
                        .map((url) => Builder(
                      builder: (context) => Image.network(url, fit: BoxFit.cover),
                    ))
                        .toList(),
                    options: CarouselOptions(
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 1,
                      height: MediaQuery.of(context).size.height / 3,
                    ),
                  );
                }
              },
            ),
          ),

          // Section Title - Books + See More Button
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Books",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllBooksScreen()),
                      );
                    },
                    child: const Text("See More"),
                  ),
                ],
              ),
            ),
          ),

          // Books Section (3 cột, 3 hàng - hiển thị 9 quyển)
          FutureBuilder<List<Book>>(
            future: bookController.fetchBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                final books = snapshot.data!.take(9).toList();
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final book = books[index];
                      return GestureDetector(
                        onTap: () {
                          ref.read(booksSelected.notifier).state = book;
                          Navigator.pushNamed(context, "/bookDetails");
                        },
                        child: Card(
                          elevation: 8,
                          child: Column(
                            children: [
                              Expanded(
                                child: Image.network(
                                  book.image!,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  book.name!,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: books.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                );
              } else {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No books available.')),
                );
              }
            },
          ),

          // Section Title - Trending Books
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 16, left: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                "Trending Books",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Trending Books from Google Books API
          FutureBuilder<List<dynamic>>(
            future: googleBooksAPI.fetchTrendingBooks(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              } else if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Center(child: Text('No trending books available.')),
                );
              } else {
                final books = snapshot.data!;
                return SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      final book = books[index]['volumeInfo'];
                      final coverUrl = googleBooksAPI.getBookCover(book);

                      return Card(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Image.network(
                                coverUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                book['title'] ?? "Unknown Title",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    childCount: books.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    childAspectRatio: 0.7,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}