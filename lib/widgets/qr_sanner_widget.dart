import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:book_app/state/state_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/book.dart';
import '../screens/book_details_screen.dart';

class QRScannerPage extends ConsumerStatefulWidget {
  @override
  _QRScannerPageState createState() => _QRScannerPageState();
}

class _QRScannerPageState extends ConsumerState<QRScannerPage> {
  String qrResult = "";  // Biến chứa kết quả quét
  bool isScanned = false; // Biến kiểm tra đã quét chưa
  DatabaseReference _bookRef = FirebaseDatabase.instance.ref().child('Books');

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
                    _navigateToBookDetailsPage(qrResult);  // Chuyển đến màn hình chapters
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
  void _navigateToBookDetailsPage(String qrResult) async {
    try {
      // Lấy toàn bộ danh sách sách từ Firebase
      DataSnapshot snapshot = await _bookRef.get();

      if (snapshot.exists) {
        final booksMap = Map<String, dynamic>.from(snapshot.value as Map);

        // Tìm sách theo tên (qrResult)
        Book? foundBook;
        for (var entry in booksMap.entries) {
          final bookId = entry.key.toString(); // ID của sách
          final bookData = Map<String, dynamic>.from(entry.value);
          final book = Book.fromJson(bookData, bookId);
          if (book.name == qrResult) { // So sánh với tên quét từ QR
            foundBook = book;
            break;
          }
        }

        if (foundBook != null) {
          // Gán dữ liệu sách vào provider
          ref.read(selectedBookProvider.notifier).state = foundBook;

          // Chuyển sang màn hình BookDetails
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const BookDetails(),
            ),
          );
        } else {
          // Không tìm thấy sách
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không tìm thấy sách!")),
          );
        }
      } else {
        throw Exception("Dữ liệu trống!");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: ${e.toString()}")),
      );
    }
  }



}
