import 'package:book_app/screens/read_screen.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChapterScreen extends ConsumerWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng watch để theo dõi provider
    var book = ref.watch(booksSelected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton( // Tùy chỉnh mũi tên quay lại
          icon: const Icon(
            Icons.arrow_back, // Mũi tên quay lại
            color: Colors.white, // Đặt màu trắng cho mũi tên
          ),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Center(
          child: Text(
            book.name?.toUpperCase() ?? "Unknown",  // Kiểm tra null cho `name`
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: book.chapters != null && book.chapters!.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: book.chapters?.length,
            itemBuilder: (context, index) {
              return GestureDetector (
                onTap: () {
                  ref.read(chapterSelected.notifier).state = book.chapters![index];
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadScreen(
                        chapter: book.chapters![index],  // Truyền chapter trực tiếp
                      ),
                    ),
                  );
                },
                child: Column (
                  children: [
                    ListTile(
                      title: Text('${book.chapters?[index].name}'),
                    ),
                    const Divider(thickness: 1)
                  ],
                ),
              );
            }),
      )
          : const Center(
        child: Text('Chưa có dữ liệu'),
      ),
    );
  }
}
