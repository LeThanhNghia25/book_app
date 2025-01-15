import 'package:book_app/models/book.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../controllers/book_controller.dart';
import '../controllers/book_save_controller.dart';
import '../controllers/user_controller.dart';
import '../providers/book_providers.dart';
import '../state/state_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookDetails extends ConsumerWidget {
  const BookDetails({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider); // Lấy sách hiện tại
    final savedBooksAsync =
        ref.watch(fetchSavedBooksProvider); // Lấy danh sách sách đã lưu
    final database = FirebaseDatabase.instance;
    final bookController = BookController(database);

    if (book == null) {
      return Scaffold(
        body: const Center(child: Text('Không tìm thấy thông tin sách!')),
      );
    }

    return savedBooksAsync.when(
      data: (savedBooks) {
        // Kiểm tra xem cuốn sách hiện tại có trong danh sách đã lưu không
        final isBookmarked = savedBooks.contains(book.id);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color(0xFFF44A3E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              book.name ?? 'Chi Tiết Sách',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị thông tin sách
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Image.network(
                        book.image ?? 'https://via.placeholder.com/100',
                        height: 260,
                        width: 180,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.name ?? 'Không có tiêu đề',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.category ?? 'Không có danh mục',
                              style: const TextStyle(fontSize: 18),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 10,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // Hành động khi nhấn nút
                                    ref.read(booksSelected.notifier).state =
                                        book;
                                    Navigator.pushNamed(context, "/chapters");
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    side: const BorderSide(
                                        color: Color(0xFFF44A3E)),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: const Text(
                                    'Đọc ngay',
                                    style: TextStyle(color: Color(0xFFF44A3E)),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final bookSaveController =
                                        BookSaveController(
                                            FirebaseDatabase.instance);
                                    final user =
                                        FirebaseAuth.instance.currentUser;

                                    if (user == null) {
                                      print('Error: User not logged in');
                                      return;
                                    }

                                    final userId = user
                                        .uid; // Lấy userId từ Firebase Authentication

                                    try {
                                      if (isBookmarked) {
                                        // Hủy lưu sách
                                        await bookSaveController.removeBook(
                                            book.id!, userId);
                                      } else {
                                        // Lưu sách
                                        await bookSaveController.saveBook(
                                            book, userId);
                                      }
                                    } catch (e) {
                                      print('Error updating bookmark: $e');
                                    }
                                  },
                                  icon: Icon(
                                    isBookmarked
                                        ? Icons.bookmark
                                        : Icons.bookmark_border,
                                    color: isBookmarked
                                        ? Colors.yellow
                                        : Colors.grey,
                                  ),
                                  iconSize: 30,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Phần giới thiệu
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Giới thiệu',
                        style: TextStyle(
                            fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      // Phần description có thể thu gọn
                      DescriptionWithToggle(description: book.description),
                    ],
                  ),
                ),
                const Divider(),
                // Có thể bạn quan tâm
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Có thể bạn quan tâm',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                ),
                FutureBuilder<List<Book>>(
                  future: bookController.fetchRandomBooks(6),
                  // Lấy 6 sách ngẫu nhiên
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Lỗi: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                          child: Text('Không có sách nào được đề xuất.'));
                    } else {
                      final books = snapshot.data!;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8.0),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: books.length,
                        itemBuilder: (context, index) {
                          final book = books[index];
                          return GestureDetector(
                            onTap: () {
                              ref.read(selectedBookProvider.notifier).state =
                                  book;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const BookDetails(),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 4,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Image.network(
                                      book.image ??
                                          'https://via.placeholder.com/150',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      book.name ?? 'Không có tiêu đề',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }
                  },
                ),
                const Divider(),
                // Phần bình luận
                // Padding(
                //   padding: const EdgeInsets.all(16.0),
                //   child: const _CommentSection(),
                // ),
              ],
            ),
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      // Khi dữ liệu đang tải
      error: (error, stack) =>
          Center(child: Text('Lỗi: $error')), // Nếu có lỗi khi lấy dữ liệu
    );
  }
}

// Widget để hiển thị phần description có thể thu gọn
class DescriptionWithToggle extends StatefulWidget {
  final String? description;

  const DescriptionWithToggle({Key? key, this.description}) : super(key: key);

  @override
  _DescriptionWithToggleState createState() => _DescriptionWithToggleState();
}

class _DescriptionWithToggleState extends State<DescriptionWithToggle> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String displayText = widget.description ?? 'Không có mô tả';
    // Hiển thị 100 ký tự đầu tiên nếu mô tả dài
    if (!isExpanded && displayText.length > 100) {
      displayText = '${displayText.substring(0, 100)}...';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayText,
          style: const TextStyle(fontSize: 17),
        ),
        if ((widget.description?.length ?? 0) > 100)
          GestureDetector(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Row(
              children: [
                Text(
                  isExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: TextStyle(
                      color: const Color(0xFFF44A3E),
                      fontWeight: FontWeight.bold),
                ),
                Icon(
                  isExpanded ? Icons.arrow_upward : Icons.arrow_downward,
                  color: const Color(0xFFF44A3E),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// Widget để hiển thị phần bình luận
// class _CommentSection extends StatefulWidget {
//   const _CommentSection({Key? key}) : super(key: key);
//
//   @override
//   _CommentSectionState createState() => _CommentSectionState();
// }

// class _CommentSectionState extends State<_CommentSection> {
//   final TextEditingController _controller = TextEditingController();
//   final DatabaseReference _commentsRef = FirebaseDatabase.instance.ref('comments');
//   List<Map<String, dynamic>> _comments = [];
//
//   // Lấy tên người dùng từ Firebase Realtime Database theo userId
//   // Future<String?> _fetchUserNameById(String userId) async {
//   //   final userController = UserController(FirebaseDatabase.instance);
//   //   return await userController.fetchUserNameById(userId);  // Trả về tên người dùng
//   // }
//
//   // Xử lý gửi bình luận
//   void _submitComment() async {
//     final commentText = _controller.text;
//     if (commentText.isNotEmpty) {
//       try {
//         // Lấy userId từ FirebaseAuth
//         final userId = FirebaseAuth.instance.currentUser?.uid;
//         if (userId != null) {
//           // Lấy tên người dùng từ userId
//           final userName = await _fetchUserNameById(userId);
//
//           if (userName != null) {
//             final commentData = {
//               'text': commentText,
//               'timestamp': ServerValue.timestamp,
//               'name': userName,  // Lưu tên người dùng vào comment
//             };
//
//             await _commentsRef.push().set(commentData);
//
//             setState(() {
//               _comments.add(commentData);  // Thêm bình luận vào danh sách
//             });
//             _controller.clear();  // Xóa nội dung bình luận
//           } else {
//             print("Tên người dùng không tìm thấy.");
//           }
//         }
//       } catch (e) {
//         print('Lỗi khi gửi bình luận: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Bình luận', style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
//         const SizedBox(height: 8),
//         StreamBuilder<DatabaseEvent>(
//           stream: _commentsRef.onValue,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return const Center(child: CircularProgressIndicator());
//             } else if (snapshot.hasError) {
//               return Center(child: Text('Lỗi: ${snapshot.error}'));
//             } else if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
//               return const Center(child: Text('Chưa có bình luận nào.'));
//             } else {
//               final commentsMap = snapshot.data!.snapshot.value as Map<dynamic, dynamic>;
//               final commentsList = commentsMap.entries
//                   .map((entry) => {
//                 'text': entry.value['text'],
//                 'name': entry.value['name'], // Lấy tên người dùng từ dữ liệu
//               })
//                   .toList();
//
//               return ListView.builder(
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 itemCount: commentsList.length,
//                 itemBuilder: (context, index) {
//                   final comment = commentsList[index];
//                   return ListTile(
//                     title: Text(comment['text']),
//                     subtitle: Text(comment['name'] ?? 'Người dùng ẩn danh'), // Nếu không có tên, hiển thị "Người dùng ẩn danh"
//                   );
//                 },
//               );
//             }
//           },
//         ),
//         const Divider(),
//         Row(
//           children: [
//             Expanded(
//               child: TextField(
//                 controller: _controller,
//                 decoration: const InputDecoration(hintText: 'Thêm bình luận', border: OutlineInputBorder()),
//               ),
//             ),
//             IconButton(
//               icon: const Icon(Icons.send, color: Color(0xFFF44A3E)),
//               onPressed: _submitComment,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
// }



