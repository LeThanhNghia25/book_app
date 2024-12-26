import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  String qrResult = "";  // Biến chứa kết quả quét
  bool isScanned = false; // Biến kiểm tra đã quét chưa
  DatabaseReference _bookRef = FirebaseDatabase.instance.ref().child('Book');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFF44A3E),
        title: Text('Quét QR Code'),
      ),
      body: Column(
        children: [
          Expanded(
            child: isScanned
                ? Center(child: Text("Đã quét mã QR và chuyển màn hình"))
                : MobileScanner(
              onDetect: (BarcodeCapture barcodeCapture) {
                if (barcodeCapture.barcodes.isNotEmpty) {
                  final barcode = barcodeCapture.barcodes.first;
                  if (barcode.rawValue != null) {
                    setState(() {
                      qrResult = barcode.rawValue!;
                      isScanned = true;  // Đánh dấu là đã quét
                    });
                    _navigateToChapterPage(qrResult);  // Chuyển đến màn hình chapters
                  }
                }
              },
            ),
          ),
          if (qrResult.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Kết quả: $qrResult"),
            ),
        ],
      ),
    );
  }

  // Hàm tìm quyển sách theo tên từ cơ sở dữ liệu
  void _navigateToChapterPage(String bookName) async {
    final snapshot = await _bookRef.get();

    if (snapshot.exists) {
      var booksList = snapshot.value as List;
      for (var bookData in booksList) {
        if (bookData['Name'] == bookName) {
          // Lưu quyển sách vào provider và điều hướng đến ChapterScreen
          ref.read(booksSelected.notifier).state = Book.fromJson(Map<String, dynamic>.from(bookData));
          Navigator.pushNamed(context, '/chapters');
          break;
        }
      }
    }
  }
}
