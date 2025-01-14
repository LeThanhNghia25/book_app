class Book {
  String? id;
  String? category;
  String? name;
  String? image;
  String? description; // Thêm thuộc tính này
  List<Chapter>? chapters;

  Book({this.id, this.category, this.name, this.image, this.description, this.chapters});

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];
    description = json['Description']; // Đọc từ JSON
    if (json['Chapters'] != null) {
      chapters = (json['Chapters'] as List)
          .map((e) => Chapter.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['Category'] = category;
    data['Name'] = name;
    data['Image'] = image;
    data['Description'] = description; // Ghi vào JSON
    if (chapters != null) {
      data['Chapters'] = chapters!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Book copyWith({String? id, String? name, String? category, String? image}) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}

class Chapter {
  List<String>? links;
  String? name;

  Chapter({this.links, this.name});

  Chapter.fromJson(Map<String, dynamic> json) {
    links = (json['Links'] != null) ? json['Links'].cast<String>() : [];
    name = json['Name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Links'] = links;
    data['Name'] = name;
    return data;
  }
}
