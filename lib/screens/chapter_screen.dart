import 'package:book_app/screens/read_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/state_manager.dart';

class ChapterScreen extends ConsumerWidget {
  const ChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(booksSelected);

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
      body: book.chapters != null && book.chapters!.isNotEmpty
          ? Padding(
        padding: const EdgeInsets.all(8),
        child: ListView.builder(
          itemCount: book.chapters?.length ?? 0, // Bảo đảm itemCount không null
          itemBuilder: (context, index) {
            final chapter = book.chapters![index];
            return GestureDetector(
              onTap: () {
                // Cập nhật `chapterSelected`
                ref.read(chapterSelected.notifier).state = chapter;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ReadScreen(chapter: chapter), // Truyền chương
                  ),
                );
              },
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      chapter.name ?? 'Chương không có tên', // Kiểm tra null cho tên chương
                    ),
                  ),
                  const Divider(thickness: 1),
                ],
              ),
            );
          },
        ),
      )
          : const Center(child: Text('Chưa có dữ liệu')),
    );
  }
}