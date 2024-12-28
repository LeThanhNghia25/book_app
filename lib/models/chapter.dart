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
