import 'package:book_app/models/book.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadScreen extends ConsumerWidget {
  final Chapter chapter;
  const ReadScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final book = ref.watch(booksSelected); // Lấy thông tin sách từ provider
    final currentChapter = ref.watch(chapterSelected); // Lấy chương hiện tại

    // Debug dữ liệu
    print('Book: ${book.toJson()}');
    print('Current Chapter: ${currentChapter.toJson()}');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Center(
          child: Text(
            book.name?.toUpperCase() ?? "Unknown",
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: book.type == 'Comic'
            ? (currentChapter.links != null && currentChapter.links!.isNotEmpty
            ? ListView.builder(
          itemCount: currentChapter.links?.length ?? 0,
          itemBuilder: (context, index) {
            return Image.network(
              currentChapter.links![index],
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
            );
          },
        )
            : const Center(child: Text('Không có hình ảnh cho chương này.')))
            : book.type == 'Text'
            ? (currentChapter.content != null &&
            currentChapter.content!.isNotEmpty
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Chiều cao vừa đủ
              crossAxisAlignment: CrossAxisAlignment.start, // Căn lề trái
              children: [
                Align(
                  alignment: Alignment.topLeft, // Căn từ trên cùng
                  child: Text(
                    currentChapter.content!,
                    style: const TextStyle(fontSize: 18.0),
                  ),
                ),
              ],
            ),
          ),
        )
            : const Center(child: Text('Chương đang được dịch...')))
            : const Center(child: Text('Loại sách không hợp lệ.')),
      ),
    );
  }
}