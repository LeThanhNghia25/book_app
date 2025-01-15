class Comment {
  final String userId;
  final String userName;
  final String text;

  Comment({
    required this.userId,
    required this.userName,
    required this.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'UserId': userId,
      'UserName': userName,
      'Text': text,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['UserId'] ?? '',
      userName: map['UserName'] ?? 'Anonymous',
      text: map['Text'] ?? '',
    );
  }
}
