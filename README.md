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

## Publishing

Publishing is handled by [Melos](https://melos.invertase.dev/). Packages use conventional commits for automated versioning and changelog generation.

### Version a package

```bash
# Auto-version based on conventional commits
melos version

# Manually bump a specific package
melos version --manual-version=butter_search_bar:patch
```

### Publish to pub.dev

```bash
# Dry-run first (checks LICENSE, README, CHANGELOG, pubspec fields)
melos publish

# Run analyze + tests before publishing
melos run analyze && melos run test

# Publish for real
melos publish --no-dry-run
```

### Conventional commits

Use these prefixes so `melos version` can auto-detect the bump:

| Prefix | Bump | Example |
|--------|------|---------|
| `fix:` | patch | `fix(search_bar): handle null suggestions` |
| `feat:` | minor | `feat(search_bar): add dimension filters` |
| `feat!:` or `BREAKING CHANGE:` | major | `feat!: remove deprecated API` |

## Packages

| Package | Version | Description |
|---------|---------|-------------|
| [butter_search_bar](packages/butter_search_bar) | 0.1.0 | Search bar with animations, suggestions, and inline filter dimensions |
| [smooth_button](packages/smooth_button) | 0.1.0 | An animated button widget with customizable properties |
| [smooth_error](packages/smooth_error) | 0.1.0 | Error and empty state widgets with sensible defaults |
| [smooth_toast](packages/smooth_toast) | 0.1.0 | Stackable in-app toast notifications with slide-in animation |
| [smooth_carousel](packages/smooth_carousel) | 0.1.0 | Image carousel with page indicators and navigation arrows |
| [smooth_badge](packages/smooth_badge) | 0.1.0 | Colored pill badges with auto-contrast text |
| [smooth_overlay](packages/smooth_overlay) | 0.1.0 | Dismissible card overlay with close button and optional hints |
