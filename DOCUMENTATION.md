# Binsync App Documentation

## Overview

Binsync is a Flutter-based mobile application designed for garbage tracking and route plotting using OpenStreetMap. This starter code provides a solid foundation for building a comprehensive waste management solution.

## Architecture

### Main Components

#### 1. BinsyncApp (Root Widget)
- Entry point of the application
- Configures Material Design theme
- Sets up app-wide configuration

#### 2. MapScreen (Main Screen)
- Displays interactive OpenStreetMap
- Manages map state and markers
- Handles user interactions

### Key Features Implementation

#### OpenStreetMap Integration
The app uses `flutter_map` package with OpenStreetMap tiles:
```dart
TileLayer(
  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.example.binsync',
  maxZoom: 19,
)
```

#### Marker System
- **Pre-loaded markers**: Three sample garbage bin locations
- **Dynamic markers**: Users can add new bins by tapping the map
- **Visual indicators**: Different colors represent different bin types/statuses

#### Map Controls
- **Zoom In/Out**: Floating action buttons for zoom control
- **Reset Location**: App bar button to return to initial view
- **Clear Markers**: Reset markers to default state

## Code Structure

```
lib/
└── main.dart
    ├── main()                    # App entry point
    ├── BinsyncApp                # Root widget
    └── MapScreen                 # Main map interface
        ├── _MapScreenState       # State management
        ├── _initializeMarkers()  # Setup sample markers
        └── _addMarker()          # Add new markers dynamically
```

## Customization Guide

### Changing Initial Location

Modify the `_initialCenter` variable in `MapScreen`:
```dart
final LatLng _initialCenter = LatLng(YOUR_LAT, YOUR_LONG);
```

### Changing Initial Zoom Level

Adjust the `_initialZoom` variable:
```dart
final double _initialZoom = 15.0; // Increase for closer view
```

### Customizing Markers

Modify the marker creation in `_initializeMarkers()` or `_addMarker()`:
```dart
Marker(
  point: LatLng(lat, lng),
  width: 40,
  height: 40,
  child: const Icon(
    Icons.delete,
    color: Colors.red,
    size: 40,
  ),
)
```

### Adding Custom Marker Icons

Replace the Icon widget with custom images:
```dart
child: Image.asset('assets/bin_icon.png'),
```

Don't forget to add the asset to `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/bin_icon.png
```

## Future Enhancements

### Recommended Features to Add

1. **GPS Location Tracking**
   - Get user's current location
   - Center map on user position
   - Track movement in real-time

2. **Route Planning**
   - Calculate optimal routes between bins
   - Display turn-by-turn navigation
   - Estimate time and distance

3. **Bin Information**
   - Store metadata (type, capacity, last collection)
   - Display info when marker is tapped
   - Edit/delete markers

4. **Backend Integration**
   - Save markers to database
   - Sync across devices
   - Multi-user support

5. **Offline Support**
   - Cache map tiles
   - Store markers locally
   - Sync when online

6. **Advanced Filtering**
   - Filter bins by type/status
   - Search functionality
   - Custom layers

## Dependencies Explained

### flutter_map (^6.0.0)
A versatile Flutter widget for displaying maps. Features:
- Multiple tile layer support
- Marker layers
- Polyline/polygon support
- Plugin ecosystem

### latlong2 (^0.9.0)
Geographic coordinate handling:
- LatLng coordinate objects
- Distance calculations
- Geographic utilities

## Performance Considerations

### Map Optimization
- Limit number of visible markers
- Use marker clustering for dense areas
- Implement viewport-based loading

### State Management
- Current implementation uses setState
- Consider BLoC or Riverpod for complex apps
- Separate business logic from UI

## Testing

### Widget Tests
Run existing widget tests:
```bash
flutter test
```

### Integration Tests
Add integration tests for:
- Map interaction
- Marker addition/removal
- Navigation between screens

## Deployment

### Android
1. Configure signing in `android/app/build.gradle`
2. Build release APK:
   ```bash
   flutter build apk --release
   ```

### iOS
1. Configure signing in Xcode
2. Build release:
   ```bash
   flutter build ios --release
   ```

### Web
Build for web deployment:
```bash
flutter build web --release
```

## Troubleshooting

### Common Issues

**Map tiles not loading**
- Check internet connection
- Verify user agent in TileLayer
- Check for CORS issues on web

**Markers not appearing**
- Verify coordinates are valid
- Check marker size settings
- Ensure MarkerLayer is added to FlutterMap

**Build errors**
- Run `flutter pub get`
- Clear build cache: `flutter clean`
- Update Flutter: `flutter upgrade`

## Contributing

When contributing to this project:
1. Follow Flutter style guide
2. Run `flutter analyze` before committing
3. Add tests for new features
4. Update documentation

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [flutter_map Documentation](https://docs.fleaflet.dev/)
- [OpenStreetMap](https://www.openstreetmap.org/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
