import 'package:flutter/material.dart';
import 'package:smooth_badge/smooth_badge.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('SmoothBadge Example')),
        body: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SmoothBadge.status(
                text: 'Active',
                status: SmoothBadgeStatus.success,
              ),
              SmoothBadge.status(
                text: 'Pending',
                status: SmoothBadgeStatus.warning,
              ),
              SmoothBadge.status(
                text: 'Failed',
                status: SmoothBadgeStatus.error,
              ),
              SmoothBadge.status(
                text: 'Draft',
                status: SmoothBadgeStatus.info,
              ),
              const SmoothBadge(
                text: 'A+',
                label: 'Rating',
                color: Colors.deepPurple,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
