import 'package:http/http.dart' as http;
import 'dart:convert';

class GoogleBooksAPI {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';

  // Lấy sách thịnh hành (trending) từ Google Books API
  Future<List<dynamic>> fetchTrendingBooks({int limit = 6}) async {
    final response = await http.get(
      Uri.parse('$_baseUrl?q=subject:fiction&orderBy=newest&maxResults=$limit'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] ?? [];
    } else {
      throw Exception('Failed to fetch trending books from Google Books');
    }
  }


  // Lấy ảnh bìa sách
  String getBookCover(Map<String, dynamic> volumeInfo) {
    if (volumeInfo['imageLinks'] != null) {
      return volumeInfo['imageLinks']['thumbnail'];
    }
    return 'https://i.imgur.com/placeholder.png';  // Ảnh mặc định nếu không có
  }
}
