import 'package:firebase_database/firebase_database.dart';

class BannerController {
  final DatabaseReference _bannerRef;

  BannerController(FirebaseDatabase database)
      : _bannerRef = database.ref().child('Banners');

  Future<List<String>> fetchBanners() async {
    final snapshot = await _bannerRef.get();
    if (snapshot.exists) {
      if (snapshot.value is Map) {
        return (snapshot.value as Map).values.map((e) => e.toString()).toList();
      } else if (snapshot.value is List) {
        return (snapshot.value as List).whereType<String>().toList();
      }
    }
    return [];
  }
}