import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

void main() {
  runApp(const BinsyncApp());
}

class BinsyncApp extends StatelessWidget {
  const BinsyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binsync - Garbage Tracking',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  
  // Default location (can be changed to user's location)
  final LatLng _initialCenter = LatLng(37.7749, -122.4194); // San Francisco
  final double _initialZoom = 13.0;
  
  // Sample markers for garbage bins
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    // Add some sample garbage bin locations
    _markers.addAll([
      Marker(
        point: LatLng(37.7749, -122.4194),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.delete,
          color: Colors.red,
          size: 40,
        ),
      ),
      Marker(
        point: LatLng(37.7849, -122.4094),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.delete,
          color: Colors.green,
          size: 40,
        ),
      ),
      Marker(
        point: LatLng(37.7649, -122.4294),
        width: 40,
        height: 40,
        child: const Icon(
          Icons.delete,
          color: Colors.orange,
          size: 40,
        ),
      ),
    ]);
  }

  void _addMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(
          point: point,
          width: 40,
          height: 40,
          child: const Icon(
            Icons.delete,
            color: Colors.blue,
            size: 40,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Binsync - Garbage Tracking'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              // Reset to initial location
              _mapController.move(_initialCenter, _initialZoom);
            },
            tooltip: 'Reset Location',
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _initialCenter,
          initialZoom: _initialZoom,
          onTap: (tapPosition, point) {
            // Add marker on tap
            _addMarker(point);
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.binsync',
            maxZoom: 19,
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'zoom_in',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom + 1,
              );
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'zoom_out',
            onPressed: () {
              final currentZoom = _mapController.camera.zoom;
              _mapController.move(
                _mapController.camera.center,
                currentZoom - 1,
              );
            },
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'clear_markers',
            onPressed: () {
              setState(() {
                _markers.clear();
                _initializeMarkers();
              });
            },
            child: const Icon(Icons.clear),
          ),
        ],
      ),
    );
  }
}
