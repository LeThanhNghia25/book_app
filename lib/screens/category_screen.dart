import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../controllers/book_details_controller.dart';
import '../models/book.dart';
import '../state/state_manager.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<String> categories = [];
  List<Map<String, dynamic>> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadCategoriesFromFirebase();
  }

  // Fetch danh sách thể loại từ Firebase
  Future<void> loadCategoriesFromFirebase() async {
    try {
      // Truy vấn Firebase để lấy danh sách sách
      DatabaseReference bookRef = FirebaseDatabase.instance.ref('Books');
      DataSnapshot snapshot = await bookRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        // Chuyển đổi snapshot.value sang Map<dynamic, dynamic>
        final booksMap = snapshot.value as Map<dynamic, dynamic>;

        // Lấy danh mục từ các cuốn sách
        final List<String> loadedCategories = booksMap.entries
            .map((entry) => entry.value['Category'])
            .where((category) => category != null && category is String)
            .expand((category) => (category as String).split(',').map((cat) => cat.trim()))
            .toSet()
            .toList();

        // Cập nhật danh sách sách và danh mục
        setState(() {
          categories = loadedCategories;
          books = booksMap.entries.map((entry) {
            final book = entry.value as Map<dynamic, dynamic>;
            return {
              'name': book['Name'] ?? 'Tên sách không xác định',
              'category': book['Category'] ?? '',
              'image': book['Image'] ?? '',
              'chapters': book['Chapters'] ?? [],
            };
          }).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back, color: Colors.white),
        //   onPressed: () => Navigator.pop(context),
        // ),
        title: const Center(
          child: Text(
            'THỂ LOẠI',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : categories.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BooksByCategoryScreen(
                      category: categories[index],
                      books: books,
                    ),
                  ),
                );
              },
              child: Column(
                children: [
                  ListTile(
                    title: Text(categories[index]),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            );
          },
        ),
      )
          : const Center(child: Text('Không có thể loại nào.')),
    );
  }
}

class BooksByCategoryScreen extends ConsumerWidget {
  final String category;
  final List<Map<String, dynamic>> books;

  const BooksByCategoryScreen({
    required this.category,
    required this.books,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredBooks = books.where((book) {
      final bookCategories = (book['category'] as String)
          .split(',')
          .map((cat) => cat.trim().toLowerCase())
          .toList();

      return bookCategories.contains(category.trim().toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: filteredBooks.isNotEmpty
          ? CustomScrollView(
        slivers: [
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.7,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final book = filteredBooks[index];
                return GestureDetector(
                  onTap: () {
                    ref.read(selectedBookProvider.notifier).state = Book.fromJson(book);
                    Navigator.pushNamed(context, "/bookDetails");
                  },
                  child: Card(
                    elevation: 8,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            book['image'],
                            fit: BoxFit.cover,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            book['name'],
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: filteredBooks.length,
            ),
          ),
        ],
      )
          : const Center(child: Text('Không có sách nào trong thể loại này')),
    );
  }
}
