import 'package:flutter/material.dart';
import 'package:smooth_error/smooth_error.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmoothError Example')),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('SmoothErrorCard (full)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SmoothErrorCard.network(onRetry: () => debugPrint('Retry!')),
            const SizedBox(height: 24),
            const Text('SmoothErrorCard (compact)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SmoothErrorCard.empty(compact: true),
          ],
        ),
      ),
    );
  }
}
