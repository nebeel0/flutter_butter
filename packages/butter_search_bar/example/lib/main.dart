import 'package:flutter/material.dart';
import 'package:butter_search_bar/butter_search_bar.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const ExampleHome(),
    );
  }
}

class ExampleHome extends StatefulWidget {
  const ExampleHome({super.key});

  @override
  State<ExampleHome> createState() => _ExampleHomeState();
}

class _ExampleHomeState extends State<ExampleHome> {
  final _expandableController = ButterSearchBarController();

  static const _fruits = [
    'Apple',
    'Banana',
    'Cherry',
    'Date',
    'Elderberry',
    'Fig',
    'Grape',
    'Honeydew',
  ];

  @override
  void dispose() {
    _expandableController.dispose();
    super.dispose();
  }

  List<Widget> _buildSuggestions(
    BuildContext context,
    ButterSearchBarController controller,
  ) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return [];
    final matches =
        _fruits.where((f) => f.toLowerCase().contains(query)).toList();
    return matches
        .map((f) => ListTile(
              title: Text(f),
              onTap: () {
                controller.text = f;
                debugPrint('Selected: $f');
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ButterSearchBar Example')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Inline Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ButterSearchBar(
              hintText: 'Search fruits...',
              suggestionsBuilder: _buildSuggestions,
              onSubmitted: (value) => debugPrint('Submitted: $value'),
            ),
            const SizedBox(height: 32),
            const Text(
              'Expandable Search',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ButterSearchBar.expandable(
              controller: _expandableController,
              hintText: 'Search...',
              expandDirection: ExpandDirection.right,
            ),
          ],
        ),
      ),
    );
  }
}
