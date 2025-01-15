class SavedBooks {
  final String sbId;
  final String bookId;
  final String userId;

  SavedBooks({
    required this.sbId,
    required this.bookId,
    required this.userId,
  });

  factory SavedBooks.fromMap(Map<String, dynamic> map) {
    return SavedBooks(
      sbId: map['sbId'], // Added sbId here
      bookId: map['bookId'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sbId': sbId, // Added sbId here
      'bookId': bookId,
      'userId': userId,
    };
  }
}
