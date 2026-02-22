import 'package:flutter/material.dart';
import 'package:smooth_toast/smooth_toast.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Builder(
        builder: (context) {
          SmoothToast.setNavigatorKey(navigatorKey);

          return Scaffold(
            appBar: AppBar(title: const Text('SmoothToast Example')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(
                    onPressed: () => SmoothToast.success('Item saved!'),
                    child: const Text('Success'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => SmoothToast.error('Something failed'),
                    child: const Text('Error'),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => SmoothToast.info('FYI'),
                    child: const Text('Info'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
