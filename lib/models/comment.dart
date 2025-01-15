class Comment {
  final String userId;
  final String userName;
  final String content;

  Comment({required this.userId, required this.userName, required this.content});

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'content': content,
    };
  }

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      userId: map['userId'],
      userName: map['userName'],
      content: map['content'],
    );
  }
}
