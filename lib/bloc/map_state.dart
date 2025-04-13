import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapState {}

class MapInitial extends MapState {}

class MapLoaded extends MapState {
  final CameraPosition initialPosition;
  final Set<Marker> markers;
  final String? path;

  MapLoaded({required this.initialPosition, required this.markers, this.path});
}

class MapDirectorySelected extends MapState {
  final String path;

  MapDirectorySelected(this.path);
}

class MapIntegrated extends MapState {
  final String path;

  MapIntegrated(this.path);
}

class MapConfigured extends MapState {
  final String path;
  final String apiKey;

  MapConfigured({required this.path, required this.apiKey});
}

class MapError extends MapState {
  final String message;

  MapError(this.message);
}
