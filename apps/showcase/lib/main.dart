import 'package:flutter/material.dart';
import 'package:butter_search_bar/butter_search_bar.dart';
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
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const ShowcaseHome(),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  final _inlineController = ButterSearchBarController();
  final _expandableController = ButterSearchBarController();
  final _dimensionController = ButterSearchBarController();
  String _selectedItem = '';
  String _dimensionSummary = '';

  static const _cities = [
    {'name': 'San Francisco', 'country': 'US', 'icon': Icons.location_city},
    {'name': 'San Diego', 'country': 'US', 'icon': Icons.beach_access},
    {'name': 'San Jose', 'country': 'US', 'icon': Icons.computer},
    {'name': 'Santa Monica', 'country': 'US', 'icon': Icons.surfing},
    {'name': 'Seattle', 'country': 'US', 'icon': Icons.cloud},
    {'name': 'New York', 'country': 'US', 'icon': Icons.apartment},
    {'name': 'London', 'country': 'UK', 'icon': Icons.castle},
    {'name': 'Los Angeles', 'country': 'US', 'icon': Icons.movie},
    {'name': 'Paris', 'country': 'FR', 'icon': Icons.restaurant},
    {'name': 'Tokyo', 'country': 'JP', 'icon': Icons.temple_buddhist},
    {'name': 'Toronto', 'country': 'CA', 'icon': Icons.park},
    {'name': 'Berlin', 'country': 'DE', 'icon': Icons.music_note},
    {'name': 'Barcelona', 'country': 'ES', 'icon': Icons.stadium},
    {'name': 'Sydney', 'country': 'AU', 'icon': Icons.sailing},
    {'name': 'Singapore', 'country': 'SG', 'icon': Icons.business},
  ];

  static const _contacts = [
    {'name': 'Alice Chen', 'email': 'alice@example.com'},
    {'name': 'Bob Smith', 'email': 'bob@example.com'},
    {'name': 'Carol Davis', 'email': 'carol@example.com'},
    {'name': 'Dan Wilson', 'email': 'dan@example.com'},
    {'name': 'Eva Martinez', 'email': 'eva@example.com'},
    {'name': 'Frank Lee', 'email': 'frank@example.com'},
    {'name': 'Grace Kim', 'email': 'grace@example.com'},
    {'name': 'Henry Brown', 'email': 'henry@example.com'},
  ];

  static const _datePeriods = [
    'This weekend',
    'Next week',
    'Next month',
    'Any week',
  ];

  @override
  void dispose() {
    _inlineController.dispose();
    _expandableController.dispose();
    _dimensionController.dispose();
    super.dispose();
  }

  List<ButterSearchDimension> _buildDimensions() {
    return [
      ButterSearchDimension<String>(
        key: 'where',
        label: 'Where',
        icon: Icons.location_on,
        emptyDisplayValue: 'Anywhere',
        builder: (context, value, onChanged) {
          return ListView(
            shrinkWrap: true,
            children: _cities
                .map((c) => ListTile(
                      leading: Icon(c['icon'] as IconData),
                      title: Text(c['name'] as String),
                      subtitle: Text(c['country'] as String),
                      dense: true,
                      onTap: () => onChanged(c['name'] as String),
                    ))
                .toList(),
          );
        },
      ),
      ButterSearchDimension<String>(
        key: 'when',
        label: 'When',
        icon: Icons.calendar_today,
        emptyDisplayValue: 'Any week',
        builder: (context, value, onChanged) {
          return ListView(
            shrinkWrap: true,
            children: _datePeriods
                .map((p) => ListTile(
                      leading: const Icon(Icons.date_range),
                      title: Text(p),
                      dense: true,
                      onTap: () => onChanged(p),
                    ))
                .toList(),
          );
        },
      ),
      ButterSearchDimension<int>(
        key: 'who',
        label: 'Who',
        icon: Icons.people,
        emptyDisplayValue: 'Add guests',
        builder: (context, value, onChanged) {
          return ListView(
            shrinkWrap: true,
            children: List.generate(
              10,
              (i) => ListTile(
                leading: const Icon(Icons.person),
                title: Text('${i + 1} guest${i > 0 ? 's' : ''}'),
                dense: true,
                onTap: () => onChanged(i + 1),
              ),
            ),
          );
        },
      ),
    ];
  }

  List<Widget> _buildCitySuggestions(
    BuildContext context,
    ButterSearchBarController controller,
  ) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return [];
    final matches = _cities
        .where((c) =>
            (c['name'] as String).toLowerCase().contains(query) ||
            (c['country'] as String).toLowerCase().contains(query))
        .toList();
    if (matches.isEmpty) {
      return [
        const ListTile(
          leading: Icon(Icons.search_off),
          title: Text('No cities found'),
          dense: true,
        ),
      ];
    }
    return matches
        .map((c) => ListTile(
              leading: Icon(c['icon'] as IconData),
              title: Text(c['name'] as String),
              subtitle: Text(c['country'] as String),
              dense: true,
              onTap: () {
                controller.text = c['name'] as String;
                setState(() => _selectedItem = c['name'] as String);
              },
            ))
        .toList();
  }

  List<Widget> _buildContactSuggestions(
    BuildContext context,
    ButterSearchBarController controller,
  ) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return [];
    final matches = _contacts
        .where((c) =>
            (c['name'] as String).toLowerCase().contains(query) ||
            (c['email'] as String).toLowerCase().contains(query))
        .toList();
    if (matches.isEmpty) {
      return [
        const ListTile(
          leading: Icon(Icons.person_off),
          title: Text('No contacts found'),
          dense: true,
        ),
      ];
    }
    return matches
        .map((c) => ListTile(
              leading: CircleAvatar(
                child: Text((c['name'] as String)[0]),
              ),
              title: Text(c['name'] as String),
              subtitle: Text(c['email'] as String),
              dense: true,
              onTap: () {
                controller.text = c['name'] as String;
              },
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Butter Showcase')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // -- SmoothButton --
                const Center(
                  child: Text(
                    'SmoothButton',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 24),
                Center(
                  child: Wrap(
                    spacing: 16,
                    children: [
                      SmoothButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('SmoothButton tapped!')),
                          );
                        },
                        child: const Text('Tap me'),
                      ),
                      SmoothButton(
                        onPressed: () {},
                        color: Colors.teal,
                        borderRadius: 24,
                        child: const Text('Custom Style'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 48),
                const Divider(),
                const SizedBox(height: 24),

                // -- ButterSearchBar: Inline with city suggestions --
                const Text(
                  'ButterSearchBar — Inline',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Type a city name (try "san", "lon", or "to")',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ButterSearchBar(
                  controller: _inlineController,
                  hintText: 'Search cities...',
                  suggestionsBuilder: _buildCitySuggestions,
                  onSubmitted: (value) {
                    setState(() => _selectedItem = value);
                  },
                ),
                if (_selectedItem.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green),
                          const SizedBox(width: 12),
                          Text('Selected: $_selectedItem',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // -- ButterSearchBar: Expandable with contact suggestions --
                const Text(
                  'ButterSearchBar — Expandable',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the icon to expand, then search contacts',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ButterSearchBar.expandable(
                  controller: _expandableController,
                  hintText: 'Search contacts...',
                  expandDirection: ExpandDirection.right,
                  showScrim: true,
                  suggestionsBuilder: _buildContactSuggestions,
                ),

                const SizedBox(height: 32),

                // -- ButterSearchBar: Custom styled --
                const Text(
                  'ButterSearchBar — Custom Style',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Stadium shape, teal accent, with trailing icons',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ButterSearchBar(
                  hintText: 'Custom search...',
                  trailing: [
                    Icon(Icons.mic,
                        size: 20,
                        color:
                            Theme.of(context).colorScheme.onSurfaceVariant),
                  ],
                  style: ButterSearchBarStyle(
                    shape: WidgetStateProperty.all(const StadiumBorder()),
                    iconColor:
                        WidgetStateProperty.resolveWith((states) {
                      if (states.contains(WidgetState.focused)) {
                        return Colors.teal;
                      }
                      return null;
                    }),
                    cursorColor: Colors.teal,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  suggestionsBuilder: _buildCitySuggestions,
                ),

                const SizedBox(height: 32),
                const Divider(),
                const SizedBox(height: 24),

                // -- ButterSearchBar: Dimensions --
                const Text(
                  'ButterSearchBar — Dimensions',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Airbnb-style: Where · When · Who',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                ButterSearchBar(
                  controller: _dimensionController,
                  dimensions: _buildDimensions(),
                  platformMode: ButterPlatformMode.desktop,
                  onDimensionChanged: (key, value) {
                    setState(() {
                      _dimensionSummary =
                          _dimensionController.dimensionSummary;
                    });
                  },
                ),
                if (_dimensionSummary.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.travel_explore,
                              color: Colors.deepPurple),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _dimensionSummary,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _dimensionController.clearDimensions();
                              setState(() => _dimensionSummary = '');
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 48),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
