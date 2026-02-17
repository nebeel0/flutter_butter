import 'package:flutter/material.dart';
import 'package:smooth_button/smooth_button.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmoothButton Example')),
        body: Center(
          child: SmoothButton(
            onPressed: () => debugPrint('Tapped!'),
            child: const Text('Press me'),
          ),
        ),
      ),
    );
  }
}
