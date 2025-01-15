import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'books_by_category_screen.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  List<String> categories = [];
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

        // Cập nhật danh sách thể loại
        setState(() {
          categories = loadedCategories;
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