import 'package:book_app/widgets/footer.dart';
import 'package:flutter/material.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;
  final int selectedIndex;

  const BaseScreen({
    required this.child,
    this.appBar,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: child,
      bottomNavigationBar: Footer(selectedIndex: selectedIndex),  // Sử dụng Footer widget
    );
  }
}
