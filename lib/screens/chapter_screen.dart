import 'package:book_app/screens/read_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/state_manager.dart';

class ChapterScreen extends ConsumerWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(selectedBookProvider); // Lấy cuốn sách từ provider

    // Kiểm tra nếu book là null
    if (book == null || book.chapters == null || book.chapters!.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFFF44A3E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context); // Quay lại màn hình trước đó
            },
          ),
          title: const Text(
            "Không có sách hoặc chương",
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: const Center(child: Text('Chưa có sách hoặc chương nào')),
      );
    }

    // Nếu book không phải null, hiển thị chương
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Center(
          child: Text(
            book.name?.toUpperCase() ?? "Unknown",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: book.chapters!.length,
          itemBuilder: (context, index) {
            final chapter = book.chapters![index];
            return GestureDetector(
              onTap: () {
                // Cập nhật chapterSelected khi người dùng chọn chương
                ref.read(chapterSelected.notifier).state = chapter;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ReadScreen(chapter: chapter), // Truyền chương vào ReadScreen
                  ),
                );
              },
              child: Column(
                children: [
                  ListTile(
                    title: Text('${chapter.name}'),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}