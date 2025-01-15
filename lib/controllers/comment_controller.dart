import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/comment.dart';

class CommentController {
  final FirebaseDatabase _database = FirebaseDatabase.instance;

  Stream<DatabaseEvent> fetchCommentsStream(String bookId) {
    final database = _database.ref('Comments/$bookId');  // Lắng nghe các bình luận cho một bookId
    return database.onValue;  // Lắng nghe các thay đổi theo thời gian thực
  }

  Future<void> addComment(Comment comment, String bookId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final database = _database.ref('Comments/$bookId');

        // Tạo một khóa duy nhất
        final newCommentRef = database.push();

        // Lưu bình luận (không cần BookId)
        await newCommentRef.set(comment.toMap());
      } catch (e) {
        print('Lỗi khi thêm bình luận: $e');
      }
    } else {
      print('Người dùng chưa đăng nhập');
    }
  }

}
