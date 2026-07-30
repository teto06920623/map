import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map/cubit/map_cubit.dart';
import 'package:map/cubit/map_state.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MapCubit>().getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MapCubit, MapState>(
      listenWhen: (previous, current) =>
          previous.errorMessage != current.errorMessage ||
          previous.currentLocation != current.currentLocation ||
          previous.destinationLocation != current.destinationLocation,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }

        // تحريك الكاميرا فقط عند تغير النقاط لتقليل الـ Rebuilds
        if (state.destinationLocation != null) {
          _mapController.move(state.destinationLocation!, 13.0);
        } else if (state.currentLocation != null) {
          _mapController.move(state.currentLocation!, 14.0);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Map Route Planner'),
          leading: const Icon(Icons.menu),
          actions: [
            IconButton(
              icon: const Icon(Icons.layers),
              onPressed: () => context.read<MapCubit>().toggleTileLayer(),
            ),
          ],
        ),
        body: Stack(
          children: [
            // الخريطة تستمع فقط للتغيرات المباشرة للـ Map
            BlocBuilder<MapCubit, MapState>(
              buildWhen: (p, c) =>
                  p.tileType != c.tileType ||
                  p.currentLocation != c.currentLocation ||
                  p.destinationLocation != c.destinationLocation ||
                  p.routePoints != c.routePoints,
              builder: (context, state) {
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter:
                        state.currentLocation ?? const LatLng(30.0444, 31.2357),
                    initialZoom: 12.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: state.tileUrl,
                      userAgentPackageName: 'com.example.map',
                    ),
                    if (state.routePoints.isNotEmpty)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: state.routePoints,
                            strokeWidth: 5.0,
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    MarkerLayer(
                      markers: [
                        if (state.currentLocation != null)
                          Marker(
                            point: state.currentLocation!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.my_location,
                              color: Colors.blue,
                              size: 35,
                            ),
                          ),
                        if (state.destinationLocation != null)
                          Marker(
                            point: state.destinationLocation!,
                            width: 50,
                            height: 50,
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 45,
                            ),
                          ),
                      ],
                    ),
                  ],
                );
              },
            ),

            // شريط البحث
            Positioned(
              top: 15,
              left: 15,
              right: 15,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TextField(
                    controller: _searchController,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (query) =>
                        context.read<MapCubit>().searchLocation(query),
                    decoration: InputDecoration(
                      hintText: 'Enter a place name...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<MapCubit>().clearRoute();
                        },
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
            ),

            // زر تحديد الموقع الحالي
            Positioned(
              right: 15,
              bottom: 220,
              child: FloatingActionButton.small(
                heroTag: 'my_loc_btn',
                onPressed: () => context.read<MapCubit>().getCurrentLocation(),
                child: const Icon(Icons.my_location),
              ),
            ),

            // كارت التفاصيل والأزرار السفلي
            BlocBuilder<MapCubit, MapState>(
              buildWhen: (p, c) =>
                  p.destinationLocation != c.destinationLocation ||
                  p.distanceKm != c.distanceKm ||
                  p.durationMin != c.durationMin,
              builder: (context, state) {
                if (state.destinationLocation == null)
                  return const SizedBox.shrink();

                return Positioned(
                  left: 15,
                  right: 15,
                  bottom: 20,
                  child: Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Destination',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            state.destinationName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            'Lat: ${state.destinationLocation!.latitude.toStringAsFixed(4)}, Lon: ${state.destinationLocation!.longitude.toStringAsFixed(4)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.add_road,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${state.distanceKm.toStringAsFixed(1)} km',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${state.durationMin.toStringAsFixed(0)} min',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () =>
                                      context.read<MapCubit>().getRoute(),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Get Route'),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    _searchController.clear();
                                    context.read<MapCubit>().clearRoute();
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(color: Colors.red),
                                  ),
                                  child: const Text('Clear Route'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            // مؤشر التحميل (Loading indicator)
            BlocBuilder<MapCubit, MapState>(
              buildWhen: (p, c) => p.isLoading != c.isLoading,
              builder: (context, state) {
                if (!state.isLoading) return const SizedBox.shrink();
                return Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(child: CircularProgressIndicator()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
