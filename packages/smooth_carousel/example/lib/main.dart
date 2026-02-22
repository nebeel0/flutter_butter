import 'package:flutter/material.dart';
import 'package:smooth_carousel/smooth_carousel.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmoothCarousel Example')),
        body: Center(
          child: SmoothCarousel(
            height: 250,
            itemCount: 3,
            itemBuilder: (context, index) {
              return Container(
                color: [Colors.blue, Colors.green, Colors.orange][index],
                child: Center(
                  child: Text(
                    'Page ${index + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
