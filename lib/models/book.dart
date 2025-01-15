class Book {
  String? id;
  String? category;
  String? name;
  String? image;
  String? description;
  String? type; // Loại sách, ví dụ: 'comic' hoặc 'text'
  List<Chapter>? chapters;

  Book({this.id, this.category, this.name, this.image, this.description, this.type, this.chapters});

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];
    description = json['Description'];
    type = json['Type']; // Thêm trường 'Type' để phân biệt sách chữ và sách tranh
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
    data['Description'] = description;
    data['Type'] = type; // Thêm trường 'Type' vào JSON
    if (chapters != null) {
      data['Chapters'] = chapters!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  Book copyWith({String? id, String? name, String? category, String? image, String? type}) {
    return Book(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      image: image ?? this.image,
      type: type ?? this.type,
    );
  }
}

class Chapter {
  List<String>? links; // Liên kết hình ảnh (đối với sách tranh)
  String? name;
  String? content; // Nội dung (đối với sách chữ)

  Chapter({this.links, this.name, this.content});

  Chapter.fromJson(Map<String, dynamic> json) {
    links = (json['Links'] != null) ? json['Links'].cast<String>() : [];
    name = json['Name'];
    content = json['Content'] ?? ''; // Đọc trường Content
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Links'] = links;
    data['Name'] = name;
    data['Content'] = content; // Xuất Content
    return data;
  }
}