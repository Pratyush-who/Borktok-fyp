import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Use flutter_map instead of google_maps_flutter
import 'package:latlong2/latlong.dart'; // Required for flutter_map coordinates

class DogLocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;
  final String title;
  final String snippet;
  final double height;

  const DogLocationMap({
    Key? key,
    required this.latitude,
    required this.longitude,
    required this.title,
    this.snippet = "",
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FlutterMap(
          options: MapOptions(
            center: LatLng(latitude, longitude),
            zoom: 15.0,
          ),
          children: [
            // Base map layer (OpenStreetMap)
            TileLayer(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: const ['a', 'b', 'c'],
              userAgentPackageName: 'com.borktok.app',
            ),
            // Marker layer
            MarkerLayer(
              markers: [
                Marker(
                  width: 80.0,
                  height: 80.0,
                  point: LatLng(latitude, longitude),
                  builder: (ctx) => Column(
                    children: [
                      const Icon(
                        Icons.pets,
                        color: Color(0xFF5C8D89),
                        size: 30,
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                            )
                          ],
                        ),
                        child: Text(
                          title,
                          style: const TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}