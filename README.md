# flutter_butter

A mono-repo for developing, testing, and publishing Flutter widget packages to pub.dev.

## Structure

- **apps/showcase** — Flutter app that imports and displays all packages
- **packages/** — Individual widget packages published to pub.dev

## Getting Started

```bash
# Install Melos
dart pub global activate melos

# Bootstrap all packages
melos bootstrap

# Run analyzer
melos run analyze

# Run tests
melos run test

# Format code
melos run format
```

## Packages

| Package | Description |
|---------|-------------|
| [smooth_button](packages/smooth_button) | An animated button widget with customizable properties |
