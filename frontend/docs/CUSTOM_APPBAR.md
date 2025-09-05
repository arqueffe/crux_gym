# CustomAppBar Widget

A reusable AppBar widget that automatically displays the appropriate logo based on the current theme mode.

## Features

- **Theme-Aware Logo**: Automatically switches between black logo (light theme) and white logo (dark theme)
- **Full AppBar Compatibility**: Supports all standard AppBar properties
- **Two Variants**: `CustomAppBar` (with title) and `LogoOnlyAppBar` (logo only)

## Assets Required

Make sure these logo assets are available in your `pubspec.yaml`:

```yaml
flutter:
  assets:
    - assets/logo/
```

Required files:
- `assets/logo/logo_black.png` - For light theme
- `assets/logo/logo_white.png` - For dark theme

## Usage

### Basic Usage with Title

```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'My Screen Title',
    actions: [
      IconButton(
        icon: Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  ),
  body: YourScreenContent(),
)
```

### Logo Only (No Title)

```dart
Scaffold(
  appBar: LogoOnlyAppBar(
    actions: [
      IconButton(
        icon: Icon(Icons.menu),
        onPressed: () {},
      ),
    ],
  ),
  body: YourScreenContent(),
)
```

### With TabBar

```dart
Scaffold(
  appBar: CustomAppBar(
    title: 'Tabbed Screen',
    bottom: TabBar(
      tabs: [
        Tab(text: 'Tab 1'),
        Tab(text: 'Tab 2'),
      ],
    ),
  ),
  body: TabBarView(
    children: [
      // Tab content
    ],
  ),
)
```

## Properties

### CustomAppBar

| Property | Type | Description | Default |
|----------|------|-------------|---------|
| `title` | `String?` | The title text to display next to the logo | `null` |
| `actions` | `List<Widget>?` | Action widgets to display on the right | `null` |
| `automaticallyImplyLeading` | `bool` | Whether to show back button | `true` |
| `leading` | `Widget?` | Custom leading widget | `null` |
| `elevation` | `double?` | AppBar elevation | `null` |
| `backgroundColor` | `Color?` | AppBar background color | `null` |
| `centerTitle` | `bool` | Whether to center the title | `true` |
| `bottom` | `PreferredSizeWidget?` | Widget below the AppBar (e.g., TabBar) | `null` |

### LogoOnlyAppBar

Same properties as `CustomAppBar` except `title` (since it only shows the logo).

## Implementation Details

- The widget uses `Theme.of(context).brightness` to detect the current theme
- Logo height is set to 32px for `CustomAppBar` and 36px for `LogoOnlyAppBar`
- Logos are loaded from the assets folder and cached by Flutter
- The widget implements `PreferredSizeWidget` to work properly with `Scaffold.appBar`

## Migration from Standard AppBar

### Before
```dart
AppBar(
  title: Text('My Title'),
  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
  actions: [/* actions */],
)
```

### After
```dart
CustomAppBar(
  title: 'My Title',
  actions: [/* actions */],
)
```

## Theme Integration

The logo automatically adapts to your app's theme:

- **Light Theme**: Uses `logo_black.png` for good contrast
- **Dark Theme**: Uses `logo_white.png` for visibility

No additional configuration is needed - the switch happens automatically when the user changes their device theme or when you programmatically change your app's theme.
