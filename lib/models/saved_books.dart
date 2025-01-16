class SavedBooks {
  final String userId;
  final List<String> bookIds;

  SavedBooks({
    required this.userId,
    required this.bookIds,
  });

  factory SavedBooks.fromMap(String userId, Map<String, dynamic> map) {
    return SavedBooks(
      userId: userId,
      bookIds: List<String>.from(map[userId] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      userId: bookIds,
    };
  }
}
