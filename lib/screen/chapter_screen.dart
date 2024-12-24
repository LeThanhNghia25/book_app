import 'package:book_app/state/state_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'base_screen.dart';
class ChapterScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng watch để theo dõi provider
    var book = ref.watch(booksSelected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        leading: IconButton( // Tùy chỉnh mũi tên quay lại
          icon: Icon(
            Icons.arrow_back, // Mũi tên quay lại
            color: Colors.white, // Đặt màu trắng cho mũi tên
          ),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Center(
          child: Text(
            '${book.name?.toUpperCase() ?? "Unknown"}',  // Kiểm tra null cho `name`
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: book.chapters != null && book.chapters!.length > 0
          ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: book.chapters?.length,
            itemBuilder: (context, index) {
              return GestureDetector (
                onTap: () {
                  ref.read(chapterSelected.notifier).state = book.chapters![index];
                  Navigator.pushNamed(context, '/read');
                },
                child: Column (
                  children: [
                    ListTile(
                      title: Text('${book.chapters?[index].name}'),
                    ),
                    Divider(thickness: 1)
                  ],
                ),
              );
            }),
      )
          : Center(
        child: Text('Chưa có dữ liệu'),
      ),
    );
  }
}
