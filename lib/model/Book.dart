import 'Chapters.dart';

class Book {
  String? category, name, image;
  List<Chapters>? chapters;

  Book({this.category, this.name, this.image, this.chapters});

  Book.fromJson(Map<String, dynamic> json) {
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];

    // Handling the nested Chapters, kiểm tra kiểu của Chapters
    if (json['Chapters'] != null) {
      chapters = [];
      if (json['Chapters'] is List) {
        // Nếu là List thì xử lý như sau
        chapters = (json['Chapters'] as List)
            .map((e) => Chapters.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      } else if (json['Chapters'] is Map) {
        // Nếu là Map thì xử lý theo cách cũ
        json['Chapters'].forEach((key, value) {
          chapters!.add(Chapters.fromJson(Map<String, dynamic>.from(value)));
        });
      }
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Category'] = this.category;
    data['Name'] = this.name;
    data['Image'] = this.image;

    if (this.chapters != null) {
      data['Chapters'] = this.chapters!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
