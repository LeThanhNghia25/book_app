import 'package:flutter/material.dart';
import '../screen/QRSannerPage.dart';

AppBar buildHeader(BuildContext context) {
  return AppBar(
    backgroundColor: Color(0xFFF44A3E),
    title: Text('Book App', style: TextStyle(color: Colors.white)),
    actions: [
      IconButton(
        icon: Icon(Icons.search, size: 32, color: Colors.white),
        onPressed: () {
          showSearch(
            context: context,
            delegate: CustomSearch(),
          );
        },
      ),
      IconButton(
        icon: Icon(Icons.qr_code_scanner, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => QRScannerPage()),
          );
        },
      ),
    ],
  );
}

class CustomSearch extends SearchDelegate {
  List<String> allData = [
    'American', 'Italy', 'China', 'Germany', 'France', 'England', 'Vietnamese'
  ];

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, size: 27, color: Colors.black, weight: 1.0),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, size: 27, color: Colors.black, weight: 1.0),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<String> matchQuery = [];
    for (var item in allData) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(
            result,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    throw UnimplementedError();
  }
}