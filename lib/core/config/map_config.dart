import 'dart:convert';
import 'package:latlong2/latlong.dart';

/// Abstract contract for Map Tile providers.
/// Isolates tile URLs and style configurations from the UI layer.
abstract class MapTileProvider {
  String get name;
  String get styleString;
  bool get isRasterTile;
  String? get rasterTileUrl;
  String get attribution;
}

/// Standard OpenStreetMap raster tile provider styled for development.
class OpenStreetMapTileProvider implements MapTileProvider {
  const OpenStreetMapTileProvider();

  @override
  String get name => 'OpenStreetMap Development';

  @override
  bool get isRasterTile => true;

  @override
  String get rasterTileUrl => 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  @override
  String get attribution => '© OpenStreetMap contributors';

  @override
  String get styleString {
    // Standard MapLibre raster style JSON specification
    final styleJson = {
      'version': 8,
      'sources': {
        'osm-tiles': {
          'type': 'raster',
          'tiles': [rasterTileUrl],
          'tileSize': 256,
          'attribution': attribution,
          'maxzoom': 19,
        }
      },
      'layers': [
        {
          'id': 'osm-tiles-layer',
          'type': 'raster',
          'source': 'osm-tiles',
          'minzoom': 0,
          'maxzoom': 19,
        }
      ]
    };
    return jsonEncode(styleJson);
  }
}

/// Dark Mode MapLibre Raster Tile Provider for seamless theme matching.
class DarkMapTileProvider implements MapTileProvider {
  const DarkMapTileProvider();

  @override
  String get name => 'Carto Dark Matter';

  @override
  bool get isRasterTile => true;

  @override
  String get rasterTileUrl =>
      'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png';

  @override
  String get attribution => '© OpenStreetMap contributors © CARTO';

  @override
  String get styleString {
    final styleJson = {
      'version': 8,
      'sources': {
        'carto-dark-tiles': {
          'type': 'raster',
          'tiles': [
            'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
            'https://b.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
            'https://c.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
            'https://d.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png',
          ],
          'tileSize': 256,
          'attribution': attribution,
          'maxzoom': 19,
        }
      },
      'layers': [
        {
          'id': 'carto-dark-layer',
          'type': 'raster',
          'source': 'carto-dark-tiles',
          'minzoom': 0,
          'maxzoom': 19,
        }
      ]
    };
    return jsonEncode(styleJson);
  }
}

/// Centralized configuration for Map rendering across the application.
class MapConfig {
  MapConfig._();

  /// Default active tile provider (defaults to DarkMapTileProvider for Padma Dark UI)
  static MapTileProvider defaultTileProvider = const DarkMapTileProvider();

  /// Fallback OSM Tile provider
  static const MapTileProvider osmTileProvider = OpenStreetMapTileProvider();

  /// Default initial camera coordinate: AUST Campus (Tejgaon, Dhaka)
  static const LatLng austCampusLocation = LatLng(23.7639, 90.4070);

  /// Default starting camera zoom level
  static const double defaultZoom = 14.5;

  /// Default bus focus zoom level
  static const double busFocusZoom = 15.5;

  /// Minimum zoom level
  static const double minZoom = 10.0;

  /// Maximum zoom level
  static const double maxZoom = 18.5;

  /// Get current style string for MapLibre
  static String get activeStyleString => defaultTileProvider.styleString;
}
