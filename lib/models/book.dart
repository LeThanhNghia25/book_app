class Book {
  String? id;
  String? category;
  String? name;
  String? image;
  String? description;
  String? type; // text or comic
  List<Chapter>? chapters;

  Book({
    this.id,
    this.category,
    this.name,
    this.image,
    this.description,
    this.type,
    this.chapters,
  });

  Book.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    category = json['Category'];
    name = json['Name'];
    image = json['Image'];
    description = json['Description'];
    type = json['Type'];
    if (json['Chapters'] != null) {
      chapters = (json['Chapters'] as List)
          .map((e) => Chapter.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } else {
      chapters = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['Category'] = category;
    data['Name'] = name;
    data['Image'] = image;
    data['Description'] = description;
    data['Type'] = type;
    if (chapters != null && chapters!.isNotEmpty) {
      data['Chapters'] = chapters!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Chapter {
  List<String>? links;
  String? name;
  String? content;

  Chapter({this.links, this.name, this.content});

  Chapter.fromJson(Map<String, dynamic> json) {
    links = (json['Links'] != null) ? json['Links'].cast<String>() : [];
    name = json['Name'];
    content = json['Content'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['Links'] = links;
    data['Name'] = name;
    data['Content'] = content;
    return data;
  }
}
