import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../controllers/comment_controller.dart';
import '../models/comment.dart';

class CommentWidget extends StatelessWidget {
  final String bookId;
  final CommentController _commentController = CommentController();

  CommentWidget({super.key, required this.bookId});

  @override
  Widget build(BuildContext context) {
    final commentController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bình luận',
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          // Hiển thị bình luận với StreamBuilder
          StreamBuilder<DatabaseEvent>(
            stream: _commentController.fetchCommentsStream(bookId),
            // Truyền bookId vào stream
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Lỗi: ${snapshot.error}'));
              } else if (!snapshot.hasData ||
                  snapshot.data!.snapshot.value == null) {
                return const Center(child: Text('Chưa có bình luận nào.'));
              } else {
                final commentsMap = Map<String, dynamic>.from(
                    snapshot.data!.snapshot.value as Map);
                final comments = commentsMap.values.map((e) {
                  return Comment.fromMap(Map<String, dynamic>.from(e));
                }).toList();

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          title: Text(comments[index].text),
                        ),
                        // Dấu ngạch ngang giữa các bình luận
                        const Divider(
                          thickness: 1.5, // Độ dày của ngạch ngang
                          color: Colors.grey, // Màu của ngạch ngang
                        ),
                      ],
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 16),
          // Thêm bình luận mới
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    labelText: 'Thêm bình luận',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () async {
                  final commentText = commentController.text.trim();
                  if (commentText.isNotEmpty) {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      final comment = Comment(
                        userId: user.uid,
                        userName: user.displayName ?? 'Anonymous',
                        text: commentText,
                      );
                      try {
                        await _commentController.addComment(comment, bookId);
                        commentController.clear();
                      } catch (e) {
                        print('Lỗi khi thêm bình luận: $e');
                      }
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
