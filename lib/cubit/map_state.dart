// ignore_for_file: unreachable_switch_default

import 'package:latlong2/latlong.dart';

enum MapTileType { standard, satellite, dark }

class MapState {
  final bool isLoading;
  final LatLng? currentLocation;
  final LatLng? destinationLocation;
  final String destinationName;
  final List<LatLng> routePoints;
  final double distanceKm;
  final double durationMin;
  final MapTileType tileType;
  final String? errorMessage;

  const MapState({
    this.isLoading = false,
    this.currentLocation,
    this.destinationLocation,
    this.destinationName = '',
    this.routePoints = const [],
    this.distanceKm = 0.0,
    this.durationMin = 0.0,
    this.tileType = MapTileType.standard,
    this.errorMessage,
  });

  // رابط الطبقات بناءً على نوع الـ Tile
  String get tileUrl {
    switch (tileType) {
      case MapTileType.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

      case MapTileType.dark:
        return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';

      case MapTileType.standard:
      default:
        return 'https://a.basemaps.cartocdn.com/light_all/{z}/{x}/{y}.png';
    }
  }

  MapState copyWith({
    bool? isLoading,
    LatLng? currentLocation,
    LatLng? destinationLocation,
    String? destinationName,
    List<LatLng>? routePoints,
    double? distanceKm,
    double? durationMin,
    MapTileType? tileType,
    String? errorMessage,
  }) {
    return MapState(
      isLoading: isLoading ?? this.isLoading,
      currentLocation: currentLocation ?? this.currentLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      destinationName: destinationName ?? this.destinationName,
      routePoints: routePoints ?? this.routePoints,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMin: durationMin ?? this.durationMin,
      tileType: tileType ?? this.tileType,
      errorMessage: errorMessage,
    );
  }
}
