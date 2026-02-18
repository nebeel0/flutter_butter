# SmoothButton

An animated Flutter button that scales down on press and back up on release.

## Getting Started

```yaml
dependencies:
  smooth_button: ^0.1.0
```

## Usage

```dart
SmoothButton(
  onPressed: () => print('Tapped!'),
  child: const Text('Press me'),
)
```

### Custom styling

```dart
SmoothButton(
  onPressed: () {},
  color: Colors.deepPurple,
  borderRadius: 24,
  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  scaleFactor: 0.9,
  duration: const Duration(milliseconds: 200),
  child: const Text('Custom'),
)
```

## Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `onPressed` | `VoidCallback` | required | Tap callback |
| `child` | `Widget` | required | Button content |
| `color` | `Color?` | theme primary | Background color |
| `borderRadius` | `double` | `12.0` | Corner radius |
| `padding` | `EdgeInsetsGeometry` | `h:24, v:14` | Inner padding |
| `scaleFactor` | `double` | `0.95` | Scale when pressed (1.0 = no scale) |
| `duration` | `Duration` | `150ms` | Animation duration |

## License

MIT
