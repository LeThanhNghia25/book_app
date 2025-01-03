import 'package:http/http.dart' as http;
import 'dart:convert';
import '../controllers/book_controller.dart';

class OpenLibraryAPI {
  static const String _baseUrl = 'https://openlibrary.org';

  // Lấy sách ngẫu nhiên từ Open Library API
  Future<List<dynamic>> fetchRandomBooks({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.json?q=&limit=$limit&page=${DateTime.now().millisecondsSinceEpoch % 100}'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['docs'];
    } else {
      throw Exception('Failed to fetch random books from Open Library');
    }
  }

  // Lấy sách thịnh hành từ Open Library API
  Future<List<dynamic>> fetchPopularBooks({int limit = 10}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/search.json?sort=editions&limit=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['docs'];
    } else {
      throw Exception('Failed to fetch popular books from Open Library');
    }
  }

  // Fallback khi API không có dữ liệu - Lấy từ Firebase hoặc hiển thị ngẫu nhiên
  Future<List<dynamic>> fetchRecommendedBooks(BookController bookController) async {
    List<dynamic> books = [];

    try {
      books = await fetchPopularBooks(limit: 10);
    } catch (e) {
      print("Failed to fetch popular books from Open Library: $e");
    }

    if (books.isEmpty) {
      final firebaseBooks = await bookController.fetchBooks();
      books = firebaseBooks.take(10).toList();
    }

    books.shuffle();
    return books;
  }

  // Lấy bìa sách từ Open Library API
  String getBookCover(String coverId, {String size = 'M'}) {
    return 'https://covers.openlibrary.org/b/id/$coverId-$size.jpg';
  }
}
