import 'package:flutter/material.dart';

class LoadingData extends StatelessWidget {
  const LoadingData({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
