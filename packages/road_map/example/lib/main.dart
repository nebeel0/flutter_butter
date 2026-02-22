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

class RoadMapExample extends StatefulWidget {
  const RoadMapExample({super.key});

  @override
  State<RoadMapExample> createState() => _RoadMapExampleState();
}

class _RoadMapExampleState extends State<RoadMapExample> {
  late final RoadMapController _controller;

  @override
  void initState() {
    super.initState();
    _controller = RoadMapController(data: _onboardingRoadmap());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RoadMap(
      controller: _controller,
      onValidationChange: (nodeId, itemId, complete) {
        debugPrint('Validation: $nodeId/$itemId = $complete');
      },
    );
  }
}

/// A 10-node onboarding roadmap for a new developer joining a team.
RoadMapData _onboardingRoadmap() {
  return RoadMapData(
    label: 'Developer Onboarding',
    nodes: const [
      RoadMapNode(
        id: 'welcome',
        label: 'Welcome',
        content:
            'Welcome to the team! This roadmap will guide you through '
            'everything you need to get started.',
        validationItems: [
          ValidationItem(id: 'w1', label: 'Read the team handbook'),
          ValidationItem(id: 'w2', label: 'Join Slack channels'),
        ],
      ),
      RoadMapNode(
        id: 'env',
        label: 'Environment Setup',
        content:
            'Set up your local development environment with the required '
            'tools and SDKs.',
        validationItems: [
          ValidationItem(id: 'e1', label: 'Install IDE'),
          ValidationItem(id: 'e2', label: 'Install Flutter SDK'),
          ValidationItem(id: 'e3', label: 'Run flutter doctor'),
        ],
      ),
      RoadMapNode(
        id: 'repo',
        label: 'Clone Repository',
        content: 'Clone the main repository and verify you can build locally.',
        validationItems: [
          ValidationItem(id: 'r1', label: 'Clone the repo'),
          ValidationItem(id: 'r2', label: 'Run tests locally'),
        ],
      ),
      RoadMapNode(
        id: 'arch',
        label: 'Architecture Overview',
        content:
            'Understand the project architecture, package structure, '
            'and key design decisions.',
        validationItems: [
          ValidationItem(id: 'a1', label: 'Read architecture docs'),
          ValidationItem(id: 'a2', label: 'Review package diagram'),
        ],
      ),
      RoadMapNode(
        id: 'style',
        label: 'Code Style & Conventions',
        content:
            'Learn the team coding conventions, lint rules, and '
            'commit message format.',
        validationItems: [
          ValidationItem(id: 's1', label: 'Read style guide'),
          ValidationItem(id: 's2', label: 'Configure linter'),
        ],
      ),
      RoadMapNode(
        id: 'testing',
        label: 'Testing Practices',
        content:
            'Learn how to write and run unit, widget, and integration '
            'tests in this project.',
        validationItems: [
          ValidationItem(id: 't1', label: 'Read testing guide'),
          ValidationItem(id: 't2', label: 'Write a sample test'),
        ],
      ),
      RoadMapNode(
        id: 'ci',
        label: 'CI/CD Pipeline',
        content:
            'Understand the continuous integration pipeline and how '
            'deployments work.',
        validationItems: [ValidationItem(id: 'ci1', label: 'Review CI config')],
      ),
      RoadMapNode(
        id: 'first_pr',
        label: 'First Pull Request',
        content: 'Pick a good-first-issue and submit your first PR.',
        validationItems: [
          ValidationItem(id: 'pr1', label: 'Pick an issue'),
          ValidationItem(id: 'pr2', label: 'Submit PR'),
          ValidationItem(id: 'pr3', label: 'Address review feedback'),
        ],
      ),
      RoadMapNode(
        id: 'pair',
        label: 'Pair Programming Session',
        content:
            'Schedule a pairing session with a senior team member '
            'to work on a real feature.',
        validationItems: [
          ValidationItem(id: 'p1', label: 'Schedule session'),
          ValidationItem(id: 'p2', label: 'Complete session'),
        ],
      ),
      RoadMapNode(
        id: 'done',
        label: 'Onboarding Complete',
        content: 'Congratulations! You have completed the onboarding process.',
      ),
    ],
    edges: const [
      // Welcome unlocks both environment and architecture tracks.
      RoadMapEdge(source: 'welcome', target: 'env'),
      RoadMapEdge(source: 'welcome', target: 'arch'),
      // Environment track.
      RoadMapEdge(source: 'env', target: 'repo'),
      // Architecture track.
      RoadMapEdge(source: 'arch', target: 'style'),
      RoadMapEdge(source: 'arch', target: 'testing'),
      // CI requires both repo access and testing knowledge.
      RoadMapEdge(source: 'repo', target: 'ci'),
      RoadMapEdge(source: 'testing', target: 'ci'),
      // First PR requires style knowledge and CI understanding.
      RoadMapEdge(source: 'style', target: 'first_pr'),
      RoadMapEdge(source: 'ci', target: 'first_pr'),
      // Pairing requires first PR.
      RoadMapEdge(source: 'first_pr', target: 'pair'),
      // Done requires pairing.
      RoadMapEdge(source: 'pair', target: 'done'),
    ],
  );
}
