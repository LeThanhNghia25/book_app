// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
//
// class CommentScreen extends StatefulWidget {
//   final String bookId;
//
//   const CommentScreen({Key? key, required this.bookId}) : super(key: key);
//
//   @override
//   _CommentScreenState createState() => _CommentScreenState();
// }
//
// class _CommentScreenState extends State<CommentScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<String> _comments = [];
//
//   @override
//   void initState() {
//     super.initState();
//     // Lấy danh sách bình luận khi màn hình được khởi tạo
//     _fetchComments();
//   }
//
//   // Hàm lấy dữ liệu bình luận từ Firebase một lần
//   void _fetchComments() async {
//     final database = FirebaseDatabase.instance;
//     final commentsRef = database.ref('books/${widget.bookId}/comments');
//
//     try {
//       final snapshot = await commentsRef.get();
//
//       if (snapshot.exists) {
//         final commentsData = snapshot.value as Map<dynamic, dynamic>;
//         final List<String> commentsList = commentsData.values
//             .map((e) => e['text'] as String? ?? 'Bình luận không có văn bản')
//             .toList();
//
//         setState(() {
//           _comments = commentsList;  // Cập nhật danh sách bình luận
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Lỗi khi lấy bình luận: $e')),
//       );
//     }
//   }
//
//   // Hàm gửi bình luận lên Firebase
//   void _submitComment() async {
//     final comment = _controller.text;
//     if (comment.isNotEmpty) {
//       try {
//         final database = FirebaseDatabase.instance;
//         final commentsRef = database.ref('books/${widget.bookId}/comments');
//
//         // Thêm bình luận mới vào Firebase
//         await commentsRef.push().set({
//           'text': comment,
//           'timestamp': ServerValue.timestamp,
//         });
//
//         // Làm mới danh sách bình luận sau khi gửi
//         _fetchComments();
//
//         _controller.clear();
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Lỗi khi gửi bình luận: $e')),
//         );
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Bình luận"),
//       ),
//       body: Column(
//         children: [
//           // Trường nhập bình luận
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: TextField(
//               controller: _controller,
//               decoration: const InputDecoration(
//                 hintText: 'Nhập bình luận...',
//                 border: OutlineInputBorder(),
//                 suffixIcon: Icon(Icons.send),
//               ),
//               onSubmitted: (_) => _submitComment(),
//             ),
//           ),
//
//           // Hiển thị danh sách bình luận
//           Expanded(
//             child: _comments.isEmpty
//                 ? const Center(child: Text('Chưa có bình luận.'))
//                 : ListView.builder(
//               itemCount: _comments.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(_comments[index]),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
