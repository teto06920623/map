import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'map_state.dart';

class MapCubit extends Cubit<MapState> {
  MapCubit() : super(const MapState());

  // 1. جلب الموقع الحالي مع الصلاحيات
  Future<void> getCurrentLocation() async {
    emit(state.copyWith(isLoading: true, errorMessage: null));
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        emit(
          state.copyWith(isLoading: false, errorMessage: 'برجاء تفعيل الـ GPS'),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'تم رفض صلاحية الموقع',
            ),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        await Geolocator.openAppSettings();
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'الصلاحية مرفوضة دائماً، فعلها من الإعدادات',
          ),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      emit(
        state.copyWith(
          isLoading: false,
          currentLocation: LatLng(position.latitude, position.longitude),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'حدث خطأ أثناء جلب الموقع',
        ),
      );
    }
  }

  // 2. البحث عن مكان عبر Nominatim API
  Future<void> searchLocation(String query) async {
    if (query.trim().isEmpty) return;
    emit(state.copyWith(isLoading: true, errorMessage: null));

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {'User-Agent': 'FlutterMapApp'},
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final lat = double.parse(data[0]['lat']);
          final lon = double.parse(data[0]['lon']);
          final displayName = data[0]['display_name'];

          emit(
            state.copyWith(
              isLoading: false,
              destinationLocation: LatLng(lat, lon),
              destinationName: displayName,
            ),
          );
        } else {
          emit(
            state.copyWith(
              isLoading: false,
              errorMessage: 'لم يتم العثور على المكان',
            ),
          );
        }
      }
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'خطأ في الاتصال بالشبكة',
        ),
      );
    }
  }

  // 3. رسم المسار وحساب الوقت والمسافة عبر OSRM API
  Future<void> getRoute() async {
    if (state.currentLocation == null || state.destinationLocation == null) {
      emit(state.copyWith(errorMessage: 'حدد موقعك الحالي والوجهة أولاً'));
      return;
    }

    emit(state.copyWith(isLoading: true, errorMessage: null));

    final url = Uri.parse(
      'http://router.project-osrm.org/route/v1/driving/'
      '${state.currentLocation!.longitude},${state.currentLocation!.latitude};'
      '${state.destinationLocation!.longitude},${state.destinationLocation!.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes[0];
          final geometry = route['geometry']['coordinates'] as List;

          List<LatLng> points = geometry.map((coord) {
            return LatLng(coord[1].toDouble(), coord[0].toDouble());
          }).toList();

          emit(
            state.copyWith(
              isLoading: false,
              routePoints: points,
              distanceKm: (route['distance'] as num) / 1000.0,
              durationMin: (route['duration'] as num) / 60.0,
            ),
          );
        }
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'فشل في جلب المسار'));
    }
  }

  // 4. التبديل بين الخرائط (Layers)
  void toggleTileLayer() {
    final nextType = state.tileType == MapTileType.standard
        ? MapTileType.satellite
        : state.tileType == MapTileType.satellite
        ? MapTileType.dark
        : MapTileType.standard;

    emit(state.copyWith(tileType: nextType));
  }

  // 5. مسح البيانات المحددة
  void clearRoute() {
    emit(
      state.copyWith(
        destinationLocation: null,
        destinationName: '',
        routePoints: [],
        distanceKm: 0.0,
        durationMin: 0.0,
      ),
    );
  }
}
