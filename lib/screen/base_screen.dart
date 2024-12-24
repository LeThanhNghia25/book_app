import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'footer.dart';

class BaseScreen extends StatelessWidget {
  final Widget child;
  final AppBar? appBar;

  BaseScreen({required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: buildFooter(context),
    );
  }
}

