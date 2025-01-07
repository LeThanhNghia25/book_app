import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<String> categories = [];
  List<Map<String, dynamic>> books = [];

  @override
  void initState() {
    super.initState();
    loadCategoriesFromFirebase();
  }

  // Fetch danh sách thể loại từ Firebase
  Future<void> loadCategoriesFromFirebase() async {
    try {
      // Truy vấn Firebase để lấy danh sách
      DatabaseReference bookRef = FirebaseDatabase.instance.ref('Books');
      DataSnapshot snapshot = await bookRef.get();

      if (snapshot.exists && snapshot.value is Map) {
        final booksMap = snapshot.value as Map<dynamic, dynamic>;

        // In ra dữ liệu từ Firebase để kiểm tra
        booksMap.entries.forEach((entry) {
          final book = entry.value as Map<String, dynamic>;
          print('Book: ${book['Name']} - Categories: ${book['Category']}');
        });

        // Lấy thể loại từ mỗi cuốn sách và thêm vào danh sách thể loại
        final List<String> loadedCategories = booksMap.entries
            .map((entry) => entry.value['Category'] as String)
            .expand((category) => category.split(',').map((cat) => cat.trim()))
            .toSet()
            .toList();

        setState(() {
          categories = loadedCategories;
          books = booksMap.entries.map((entry) {
            final book = entry.value as Map<String, dynamic>;
            return {
              'name': book['Name'],
              'category': book['Category'],
              'image': book['Image'],
              'chapters': book['Chapters'],
            };
          }).toList();
        });
      } else {
        print('No data available.');
      }
    } catch (e) {
      print('Error loading categories from Firebase: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Center(
          child: Text(
            'THỂ LOẠI',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: categories.isNotEmpty
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
          : const Center(child: CircularProgressIndicator()),
    );
  }
}

class BooksByCategoryScreen extends StatelessWidget {
  final String category;
  final List<Map<String, dynamic>> books;

  const BooksByCategoryScreen({
    required this.category,
    required this.books,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Lọc sách theo thể loại
    final filteredBooks = books.where((book) {
      final bookCategories = (book['category'] as String)
          .split(',')
          .map((category) => category.trim().toLowerCase())
          .toList();

      // In ra các sách và danh mục để kiểm tra
      print('Checking book "${book['name']}" with categories: $bookCategories');
      print('Matching with category: "${category.trim().toLowerCase()}"');

      return bookCategories.contains(category.trim().toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        title: Center(
          child: Text(
            category.toUpperCase(),
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: filteredBooks.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: filteredBooks.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListTile(
                  leading: Image.network(
                    filteredBooks[index]['image'],
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                  title: Text(filteredBooks[index]['name']),
                ),
                const Divider(thickness: 1),
              ],
            );
          },
        ),
      )
          : const Center(child: Text('Không có sách nào trong thể loại này')),
    );
  }
}
