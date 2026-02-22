import 'package:flutter/material.dart';
import 'package:smooth_overlay/smooth_overlay.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmoothOverlayCard Example')),
        body: Center(
          child: SmoothOverlayCard(
            width: 300,
            height: 200,
            onClose: () => debugPrint('Closed!'),
            onTap: () => debugPrint('Tapped!'),
            hintText: 'Tap to expand',
            hintIcon: Icons.open_in_full,
            child: Container(
              color: Colors.blue.shade100,
              child: const Center(child: Text('Preview content')),
            ),
          ),
        ),
      ),
    );
  }
}
