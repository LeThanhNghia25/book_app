import 'package:book_app/models/book.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReadScreen extends ConsumerWidget {
  final Chapter chapter;
  const ReadScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Sử dụng watch để theo dõi provider
    var book = ref.watch(booksSelected);
    var chapter = ref.watch(chapterSelected);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF44A3E),
        leading: IconButton(
          // Tùy chỉnh mũi tên quay lại
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
            book.name?.toUpperCase() ?? "Unknown", // Kiểm tra null cho `name`
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
      body: Center(
        child: (chapter.links == null || chapter.links!.isEmpty)
            ? const Text('This chapter is translating...')
            : CarouselSlider(
          items: chapter.links
              ?.map(
                (e) => Builder(
              builder: (context) {
                return Image.network(
                  e,
                  fit: BoxFit.cover,
                );
              },
            ),
          )
              .toList(),
          options: CarouselOptions(
            autoPlay: false,
            height: MediaQuery.of(context).size.height,
            enlargeCenterPage: false,
            viewportFraction: 1,
            initialPage: 0,
          ),
        ),
      ),
    );
  }
}
