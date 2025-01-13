class Book {
  String? id, category, name, image;
  List<Chapter>? chapters;

  Book({this.id, this.category, this.name, this.image, this.chapters});


  // Chuyển từ map
  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      image: map['image'],
    );
  }

  // Chuyển thành map để lưu vào Firebase
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'image': image,
    };
  }

  // Sửa lại fromJson để nhận 1 tham số duy nhất
  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];

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
    if (chapters != null) {
      data['Chapters'] = chapters!.map((v) => v.toJson()).toList();
    }
    return data;
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



