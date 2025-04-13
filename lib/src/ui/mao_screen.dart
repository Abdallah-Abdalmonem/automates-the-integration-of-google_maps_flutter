// File: lib/src/ui/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const LatLng cairoLatLng = LatLng(30.0444, 31.2357);

    return Scaffold(
      appBar: AppBar(title: const Text('خريطة Google Map')),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: cairoLatLng,
          zoom: 12,
        ),
        markers: {
          Marker(
            markerId: MarkerId('cairo'),
            position: cairoLatLng,
            infoWindow: InfoWindow(title: 'Cairo Marker'),
          )
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
