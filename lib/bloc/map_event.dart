abstract class MapEvent {}

class LoadMap extends MapEvent {}

class SelectMapDirectory extends MapEvent {}

class IntegrateGoogleMaps extends MapEvent {}

class ConfigureApiKey extends MapEvent {
  final String apiKey;

  ConfigureApiKey(this.apiKey);
}
