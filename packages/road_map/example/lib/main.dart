import 'package:flutter/material.dart';
import 'package:road_map/road_map.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoadMap Example',
      theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
      home: const RoadMapExample(),
    );
  }
}

// ---------------------------------------------------------------------------
// Main screen
// ---------------------------------------------------------------------------

class RoadMapExample extends StatefulWidget {
  const RoadMapExample({super.key});

  @override
  State<RoadMapExample> createState() => _RoadMapExampleState();
}

class _RoadMapExampleState extends State<RoadMapExample> {
  late RoadMapController _controller;
  int _sampleIndex = 0;
  bool _listView = false;

  static final _samples = [
    (
      label: 'Vacation Planning',
      icon: Icons.flight_takeoff,
      data: _vacationPlanning(),
    ),
    (label: 'Learn Flutter', icon: Icons.school, data: _learningGoal()),
    (
      label: 'Dev Onboarding',
      icon: Icons.developer_board,
      data: _devOnboarding(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = RoadMapController(data: _samples[_sampleIndex].data);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _switchSample(int index) {
    if (index == _sampleIndex) return;
    setState(() {
      _sampleIndex = index;
      _controller.updateData(_samples[index].data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Side panel: sample picker + view toggle
        NavigationRail(
          selectedIndex: _sampleIndex,
          onDestinationSelected: _switchSample,
          labelType: NavigationRailLabelType.all,
          leading: Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: IconButton.filledTonal(
              icon: Icon(_listView ? Icons.view_agenda : Icons.list),
              tooltip: _listView ? 'Page view' : 'List view',
              onPressed: () => setState(() => _listView = !_listView),
            ),
          ),
          destinations: [
            for (final sample in _samples)
              NavigationRailDestination(
                icon: Icon(sample.icon),
                label: Text(sample.label),
              ),
          ],
        ),
        const VerticalDivider(width: 1),
        // Main content
        Expanded(child: _listView ? _buildListView() : _buildPageView()),
      ],
    );
  }

  Widget _buildPageView() {
    return RoadMap(
      controller: _controller,
      onValidationChange: (nodeId, itemId, complete) {
        debugPrint('Validation: $nodeId/$itemId = $complete');
      },
    );
  }

  Widget _buildListView() {
    return Scaffold(
      appBar: AppBar(title: Text(_samples[_sampleIndex].label)),
      body: RoadMapListView(
        controller: _controller,
        onValidationChange: (nodeId, itemId, complete) {
          debugPrint('Validation: $nodeId/$itemId = $complete');
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Sample data
// ---------------------------------------------------------------------------

RoadMapData _vacationPlanning() {
  return RoadMapData(
    label: 'Vacation Planning',
    nodes: const [
      RoadMapNode(
        id: 'dates',
        label: 'Pick Dates',
        content: 'Decide when you want to travel.',
        validationItems: [
          ValidationItem(id: 'd1', label: 'Choose departure date'),
          ValidationItem(id: 'd2', label: 'Choose return date'),
        ],
      ),
      RoadMapNode(
        id: 'passport',
        label: 'Check Passport',
        content: 'Make sure your passport is valid for at least 6 months.',
        validationItems: [
          ValidationItem(id: 'pp1', label: 'Passport is valid'),
        ],
      ),
      RoadMapNode(
        id: 'flights',
        label: 'Book Flights',
        content: 'Search and book round-trip flights.',
        validationItems: [ValidationItem(id: 'f1', label: 'Flights booked')],
      ),
      RoadMapNode(
        id: 'hotel',
        label: 'Reserve Hotel',
        content: 'Find and reserve accommodation.',
        validationItems: [ValidationItem(id: 'h1', label: 'Hotel reserved')],
      ),
      RoadMapNode(
        id: 'itinerary',
        label: 'Plan Itinerary',
        content: 'Map out daily activities and sights to see.',
        validationItems: [ValidationItem(id: 'i1', label: 'Itinerary drafted')],
      ),
      RoadMapNode(
        id: 'pack',
        label: 'Pack Bags',
        content: 'Pack everything you need for the trip.',
        validationItems: [ValidationItem(id: 'pk1', label: 'Bags packed')],
      ),
    ],
    edges: const [
      RoadMapEdge(source: 'dates', target: 'flights'),
      RoadMapEdge(source: 'dates', target: 'hotel'),
      RoadMapEdge(source: 'passport', target: 'flights'),
      RoadMapEdge(source: 'flights', target: 'itinerary'),
      RoadMapEdge(source: 'hotel', target: 'itinerary'),
      RoadMapEdge(source: 'itinerary', target: 'pack'),
    ],
  );
}

RoadMapData _learningGoal() {
  return RoadMapData(
    label: 'Learn Flutter',
    nodes: const [
      RoadMapNode(
        id: 'basics',
        label: 'Learn Dart Basics',
        content: 'Variables, functions, classes, and async.',
        validationItems: [
          ValidationItem(id: 'lb1', label: 'Complete Dart tutorial'),
          ValidationItem(id: 'lb2', label: 'Write a CLI program'),
        ],
      ),
      RoadMapNode(
        id: 'widgets',
        label: 'Understand Widgets',
        content: 'Stateless, Stateful, layout widgets, and composition.',
        validationItems: [
          ValidationItem(id: 'w1', label: 'Build a counter app'),
        ],
      ),
      RoadMapNode(
        id: 'state',
        label: 'State Management',
        content: 'Learn ChangeNotifier, Provider, or Riverpod.',
        validationItems: [
          ValidationItem(id: 'sm1', label: 'Refactor counter with Provider'),
        ],
      ),
      RoadMapNode(
        id: 'project',
        label: 'Build a Project',
        content: 'Put it all together in a real app.',
        validationItems: [
          ValidationItem(id: 'p1', label: 'App compiles and runs'),
          ValidationItem(id: 'p2', label: 'Published to GitHub'),
        ],
      ),
    ],
    edges: const [
      RoadMapEdge(source: 'basics', target: 'widgets'),
      RoadMapEdge(source: 'widgets', target: 'state'),
      RoadMapEdge(source: 'state', target: 'project'),
    ],
  );
}

RoadMapData _devOnboarding() {
  return RoadMapData(
    label: 'Developer Onboarding',
    nodes: const [
      RoadMapNode(
        id: 'welcome',
        label: 'Welcome',
        content: 'Welcome to the team! Read the handbook and join Slack.',
        validationItems: [
          ValidationItem(id: 'w1', label: 'Read the team handbook'),
          ValidationItem(id: 'w2', label: 'Join Slack channels'),
        ],
      ),
      RoadMapNode(
        id: 'env',
        label: 'Environment Setup',
        content: 'Install IDE, Flutter SDK, and run flutter doctor.',
        validationItems: [
          ValidationItem(id: 'e1', label: 'Install IDE'),
          ValidationItem(id: 'e2', label: 'Install Flutter SDK'),
          ValidationItem(id: 'e3', label: 'Run flutter doctor'),
        ],
      ),
      RoadMapNode(
        id: 'repo',
        label: 'Clone Repository',
        content: 'Clone the main repo and verify you can build locally.',
        validationItems: [
          ValidationItem(id: 'r1', label: 'Clone the repo'),
          ValidationItem(id: 'r2', label: 'Run tests locally'),
        ],
      ),
      RoadMapNode(
        id: 'arch',
        label: 'Architecture Overview',
        content: 'Understand package structure and key design decisions.',
        validationItems: [
          ValidationItem(id: 'a1', label: 'Read architecture docs'),
        ],
      ),
      RoadMapNode(
        id: 'first_pr',
        label: 'First Pull Request',
        content: 'Pick a good-first-issue and submit your first PR.',
        validationItems: [
          ValidationItem(id: 'pr1', label: 'Pick an issue'),
          ValidationItem(id: 'pr2', label: 'Submit PR'),
        ],
      ),
    ],
    edges: const [
      RoadMapEdge(source: 'welcome', target: 'env'),
      RoadMapEdge(source: 'welcome', target: 'arch'),
      RoadMapEdge(source: 'env', target: 'repo'),
      RoadMapEdge(source: 'repo', target: 'first_pr'),
      RoadMapEdge(source: 'arch', target: 'first_pr'),
    ],
  );
}
