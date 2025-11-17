# Binsync

Mobile application for garbage tracking and route plotting using Flutter and OpenStreetMap.

## Features

- 🗺️ Interactive map powered by OpenStreetMap
- 📍 Mark garbage bin locations on the map
- 🎯 Pre-loaded sample bin locations
- ➕ Add new bins by tapping on the map
- 🔍 Zoom in/out controls
- 📌 Reset to default location
- 🧹 Clear markers functionality

## Prerequisites

Before running this project, ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (version 3.0.0 or higher)
- [Dart](https://dart.dev/get-dart) (version 3.0.0 or higher)
- An IDE such as [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/DukeZyke/Binsync.git
cd Binsync
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the application

For Android/iOS:
```bash
flutter run
```

For web:
```bash
flutter run -d chrome
```

For a specific device:
```bash
flutter devices  # List available devices
flutter run -d <device_id>
```

## Project Structure

```
Binsync/
├── lib/
│   └── main.dart          # Main application file with map integration
├── pubspec.yaml           # Project dependencies and configuration
├── analysis_options.yaml  # Dart analyzer configuration
├── .gitignore            # Git ignore rules for Flutter
└── README.md             # This file
```

## Dependencies

- **flutter_map** (^6.0.0): Flutter map widget library for OpenStreetMap integration
- **latlong2** (^0.9.0): Geographic coordinate manipulation library
- **cupertino_icons** (^1.0.2): iOS style icons for Flutter

## Usage

### Map Interaction

1. **Add Markers**: Tap anywhere on the map to add a new garbage bin marker
2. **Zoom Controls**: Use the floating action buttons (+ and -) to zoom in/out
3. **Reset Location**: Click the location icon in the app bar to reset to the default location
4. **Clear Markers**: Use the clear button to remove all added markers and reset to sample locations

### Sample Markers

The app comes with three pre-loaded sample markers in the San Francisco area:
- Red marker at San Francisco center
- Green marker to the north
- Orange marker to the south

### Customization

You can customize the initial location by modifying the `_initialCenter` variable in `lib/main.dart`:

```dart
final LatLng _initialCenter = LatLng(latitude, longitude);
```

## Development

### Running Tests

```bash
flutter test
```

### Code Analysis

```bash
flutter analyze
```

### Format Code

```bash
flutter format lib/
```

## Building for Production

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is open source and available under the MIT License.

## Acknowledgments

- [OpenStreetMap](https://www.openstreetmap.org/) for providing free map tiles
- [flutter_map](https://pub.dev/packages/flutter_map) for the Flutter map widget
- The Flutter community for their excellent documentation and support
