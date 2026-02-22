import 'package:flutter/material.dart';
import 'package:road_map/road_map.dart';
import 'package:smooth_button/smooth_button.dart';

void main() {
  runApp(const ShowcaseApp());
}

class ShowcaseApp extends StatelessWidget {
  const ShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Butter Showcase',
      theme: ThemeData(colorSchemeSeed: Colors.deepPurple, useMaterial3: true),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatelessWidget {
  const ShowcaseHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Butter Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'SmoothButton',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Center(
            child: SmoothButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('SmoothButton tapped!')),
                );
              },
              child: const Text('Tap me'),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: SmoothButton(
              onPressed: () {},
              color: Colors.teal,
              borderRadius: 24,
              child: const Text('Custom Style'),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          const Text(
            'RoadMap',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('A document-style DAG navigator.'),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const _RoadMapDemo()),
              );
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('Open RoadMap Demo'),
          ),
        ],
      ),
    );
  }
}

class _RoadMapDemo extends StatefulWidget {
  const _RoadMapDemo();

  @override
  State<_RoadMapDemo> createState() => _RoadMapDemoState();
}

class _RoadMapDemoState extends State<_RoadMapDemo> {
  late final RoadMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RoadMapController(
      data: RoadMapData(
        label: 'Quick Start Guide',
        nodes: const [
          RoadMapNode(
            id: 'install',
            label: 'Install Flutter',
            content: 'Download and install the Flutter SDK.',
            validationItems: [
              ValidationItem(id: 'i1', label: 'SDK downloaded'),
              ValidationItem(id: 'i2', label: 'flutter doctor passes'),
            ],
          ),
          RoadMapNode(
            id: 'create',
            label: 'Create Project',
            content: 'Run flutter create to scaffold a new app.',
            validationItems: [
              ValidationItem(id: 'c1', label: 'Project created'),
            ],
          ),
          RoadMapNode(
            id: 'run',
            label: 'Run the App',
            content: 'Use flutter run to launch on a device or emulator.',
            validationItems: [ValidationItem(id: 'r1', label: 'App running')],
          ),
          RoadMapNode(
            id: 'test',
            label: 'Write a Test',
            content: 'Add a widget test for the default counter app.',
            validationItems: [
              ValidationItem(id: 't1', label: 'Test written'),
              ValidationItem(id: 't2', label: 'Test passes'),
            ],
          ),
          RoadMapNode(
            id: 'ship',
            label: 'Ship It',
            content: 'Build and deploy your app.',
          ),
        ],
        edges: const [
          RoadMapEdge(source: 'install', target: 'create'),
          RoadMapEdge(source: 'create', target: 'run'),
          RoadMapEdge(source: 'create', target: 'test'),
          RoadMapEdge(source: 'run', target: 'ship'),
          RoadMapEdge(source: 'test', target: 'ship'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoadMap(controller: _controller);
  }
}
