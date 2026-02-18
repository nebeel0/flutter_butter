# ButterSearchBar

A customizable Flutter search bar with smooth animations, expandable mode, floating suggestions, and Airbnb-style inline filter dimensions.

## Features

- Inline search bar with hint text, clear button, and focus callbacks
- Expandable mode with animated expand/collapse
- Floating suggestions overlay
- Inline filter dimensions with typed pickers and auto-advance
- Cross-platform adaptive behavior (mobile full-screen, desktop floating overlay)
- Keyboard shortcuts on desktop (Escape, Tab)
- Full styling control

## Getting Started

```yaml
dependencies:
  butter_search_bar: ^0.1.0
```

## Usage

### Basic search bar

```dart
ButterSearchBar(
  hintText: 'Search...',
  onChanged: (value) => print(value),
  onSubmitted: (value) => print('Submitted: $value'),
)
```

### With suggestions

```dart
ButterSearchBar(
  hintText: 'Search fruits...',
  suggestionsBuilder: (context, controller) {
    final query = controller.text.toLowerCase();
    if (query.isEmpty) return [];
    return fruits
        .where((f) => f.toLowerCase().contains(query))
        .map((f) => ListTile(
              title: Text(f),
              onTap: () => controller.text = f,
            ))
        .toList();
  },
)
```

### Expandable mode

```dart
ButterSearchBar.expandable(
  hintText: 'Search...',
  expandDirection: ExpandDirection.right,
)
```

### Filter dimensions

```dart
ButterSearchBar(
  dimensions: [
    ButterSearchDimension<String>(
      key: 'where',
      label: 'Where',
      emptyDisplayValue: 'Anywhere',
      builder: (context, value, onChanged) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('Paris'),
              onTap: () => onChanged('Paris'),
            ),
            ListTile(
              title: const Text('London'),
              onTap: () => onChanged('London'),
            ),
          ],
        );
      },
    ),
    ButterSearchDimension<String>(
      key: 'when',
      label: 'When',
      emptyDisplayValue: 'Any week',
      builder: (context, value, onChanged) {
        return ListView(
          shrinkWrap: true,
          children: [
            ListTile(
              title: const Text('This weekend'),
              onTap: () => onChanged('This weekend'),
            ),
          ],
        );
      },
    ),
  ],
  onDimensionChanged: (key, value) {
    print('$key changed to $value');
  },
)
```

### Platform mode override

```dart
// Force desktop overlay behavior even on narrow screens
ButterSearchBar(
  dimensions: myDimensions,
  platformMode: ButterPlatformMode.desktop,
)
```

## License

MIT
