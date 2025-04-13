import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'map_event.dart';
import 'map_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  String? projectPath;

  MapBloc() : super(MapInitial()) {
    on<LoadMap>((event, emit) {
      final initialPosition = CameraPosition(
        target: LatLng(30.0444, 31.2357), // Cairo
        zoom: 12,
      );

      final marker = Marker(
        markerId: MarkerId('cairo'),
        position: LatLng(30.0444, 31.2357),
        infoWindow: InfoWindow(title: 'Cairo Marker'),
      );

      emit(MapLoaded(
          initialPosition: initialPosition,
          markers: {marker},
          path: projectPath));
    });

    on<SelectMapDirectory>((event, emit) async {
      try {
        // Open directory picker
        final result = await FilePicker.platform.getDirectoryPath();

        if (result == null) {
          emit(MapError('No directory selected'));
          return;
        }

        // Validate if it's a Flutter project (check for pubspec.yaml)
        final pubspecFile = File('$result/pubspec.yaml');
        if (!await pubspecFile.exists()) {
          emit(MapError('Invalid Flutter project: pubspec.yaml not found'));
          return;
        }

        projectPath = result;
        emit(MapDirectorySelected(result));
      } catch (e) {
        emit(MapError('Error selecting directory: ${e.toString()}'));
      }
    });

    on<IntegrateGoogleMaps>((event, emit) async {
      if (projectPath == null) {
        emit(MapError('Please select a Flutter project directory first'));
        return;
      }

      try {
        // Add google_maps_flutter to pubspec.yaml if not already added
        final pubspecFile = File('$projectPath/pubspec.yaml');
        String pubspecContent = await pubspecFile.readAsString();

        if (!pubspecContent.contains('google_maps_flutter:')) {
          // Find dependencies section and add google_maps_flutter
          final dependenciesIndex = pubspecContent.indexOf('dependencies:');
          if (dependenciesIndex == -1) {
            emit(MapError('Invalid pubspec.yaml format'));
            return;
          }

          // Insert after dependencies section
          final lines = pubspecContent.split('\n');
          int insertIndex = -1;

          for (int i = 0; i < lines.length; i++) {
            if (lines[i].trim() == 'dependencies:') {
              insertIndex = i + 1;
              while (insertIndex < lines.length &&
                  (lines[insertIndex].trim().isEmpty ||
                      lines[insertIndex].startsWith('  '))) {
                insertIndex++;
              }
              break;
            }
          }

          if (insertIndex != -1) {
            lines.insert(insertIndex, '  google_maps_flutter: ^2.10.1');
            pubspecContent = lines.join('\n');
            await pubspecFile.writeAsString(pubspecContent);
          }
        }

        // Run flutter pub get
        final process = await Process.run('flutter.bat', ['pub', 'get'],
            workingDirectory: projectPath);

        if (process.exitCode != 0) {
          emit(MapError('Failed to run flutter pub get: ${process.stderr}'));
          return;
        }

        emit(MapIntegrated(projectPath!));
      } catch (e) {
        emit(MapError('Error integrating Google Maps: ${e.toString()}'));
      }
    });

    on<ConfigureApiKey>((event, emit) async {
      if (projectPath == null) {
        emit(MapError('Please select a Flutter project directory first'));
        return;
      }

      try {
        // Configure Android
        final androidManifestFile =
            File('$projectPath/android/app/src/main/AndroidManifest.xml');
        if (await androidManifestFile.exists()) {
          String manifestContent = await androidManifestFile.readAsString();

          // Check if API key is already configured
          if (!manifestContent.contains('com.google.android.geo.API_KEY')) {
            // Add the meta-data for Google Maps API key
            final metaDataTag =
                '\n        <meta-data\n            android:name="com.google.android.geo.API_KEY"\n            android:value="${event.apiKey}" />\n';

            // Insert before the closing application tag
            final insertIndex = manifestContent.lastIndexOf('</application>');
            if (insertIndex != -1) {
              manifestContent = manifestContent.substring(0, insertIndex) +
                  metaDataTag +
                  manifestContent.substring(insertIndex);
              await androidManifestFile.writeAsString(manifestContent);
            }
          }
        }

        // Configure iOS
        final iosInfoPlistFile = File('$projectPath/ios/Runner/Info.plist');
        if (await iosInfoPlistFile.exists()) {
          String plistContent = await iosInfoPlistFile.readAsString();

          // Check if API key is already configured
          if (!plistContent.contains('io.flutter.embedded_views_preview')) {
            // Add the required keys for Google Maps
            final insertIndex = plistContent.lastIndexOf('</dict>');
            if (insertIndex != -1) {
              final iosConfig = '''
	<key>io.flutter.embedded_views_preview</key>
	<true/>
	<key>NSLocationWhenInUseUsageDescription</key>
	<string>This app needs access to location when open.</string>
	<key>NSLocationAlwaysUsageDescription</key>
	<string>This app needs access to location when in the background.</string>
	<key>com.google.ios.maps.APIKey</key>
	<string>${event.apiKey}</string>
''';
              plistContent = plistContent.substring(0, insertIndex) +
                  iosConfig +
                  plistContent.substring(insertIndex);
              await iosInfoPlistFile.writeAsString(plistContent);
            }
          }
        }

        // Update AppDelegate.swift for iOS
        final iosAppDelegateFile =
            File('$projectPath/ios/Runner/AppDelegate.swift');
        if (await iosAppDelegateFile.exists()) {
          String appDelegateContent = await iosAppDelegateFile.readAsString();

          // Check if Google Maps is already initialized
          if (!appDelegateContent.contains('GMSServices')) {
            // Add import for GoogleMaps
            if (!appDelegateContent.contains('import GoogleMaps')) {
              appDelegateContent = appDelegateContent.replaceFirst(
                  'import UIKit', 'import UIKit\nimport GoogleMaps');
            }

            // Add GMSServices.provideAPIKey
            final registerIndex = appDelegateContent
                .indexOf('GeneratedPluginRegistrant.register');
            if (registerIndex != -1) {
              // Find the line with GeneratedPluginRegistrant.register
              final lines = appDelegateContent.split('\n');
              int lineIndex = -1;

              for (int i = 0; i < lines.length; i++) {
                if (lines[i].contains('GeneratedPluginRegistrant.register')) {
                  lineIndex = i;
                  break;
                }
              }

              if (lineIndex != -1) {
                lines.insert(lineIndex,
                    '    GMSServices.provideAPIKey("${event.apiKey}")');
                appDelegateContent = lines.join('\n');
                await iosAppDelegateFile.writeAsString(appDelegateContent);
              }
            }
          }
        }

        emit(MapConfigured(path: projectPath!, apiKey: event.apiKey));
      } catch (e) {
        emit(MapError('Error configuring API key: ${e.toString()}'));
      }
    });
  }
}
