import 'package:firefinder/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:firefinder/main.dart';
import 'package:url_launcher/url_launcher.dart';

class FiresMap extends StatelessWidget {
  const FiresMap({
    super.key,
    required this.mapController,
    required this.screenSize
  });

  final MapController mapController;
  final Size screenSize;

  @override
  Widget build(BuildContext context) {
    var fires = context.watch<MyAppState>().fires;

    return FutureBuilder<Map<String, dynamic>>(
      future: fires,
      builder: (context, snapshot) {
        var points = <Marker>[];
        var polygons = <Polygon>[];
        final LayerHitNotifier hitNotifier = ValueNotifier(null);

        if (snapshot.data != null) {
          for (final feature in snapshot.data!['features']) {
            if (feature['geometry']['type'] == "Point") {
              // Add it to the points layer
              points.add(Marker(
                point: LatLng(feature['geometry']['coordinates'][1], feature['geometry']['coordinates'][0]),
                child: GestureDetector(
                  // TODO: Replace icon
                  child: const Icon(Icons.local_fire_department, size: 30, color: Color.fromARGB(255, 216, 135, 13),),
                  onTap: () {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        // Potential improvement: Show data such as last update and number of vehicles en route and on scene.
                        return FireInfoDialog(fireData: feature,);
                      }
                    );
                  },
                ),
              ));
            } else if (feature['geometry']['type'] == "Polygon") {
              // Add it to the polygon layer
              // Polygons cannot be tapped for more info - shortcoming of flutter_map currently.
              // There are few enough polygons that it could be possible to search through polygons manually
              // upon tap, but not implemented (yet).
              polygons.add(Polygon(
                points: [for (var i in feature['geometry']['coordinates'][0]) LatLng(i[1], i[0])],
                borderColor: const Color.fromARGB(255, 216, 135, 13),
                borderStrokeWidth: 2,
                color: const Color.fromARGB(120, 216, 135, 13),
                hitValue: feature
              ));
            }
          }
        }

        return FlutterMap(
          mapController: mapController,
          options: MapOptions(
            // screenSize: screenSize,
            initialCenter: const LatLng(-22.107471, 149.50843),
            initialZoom: 6,
            maxZoom: 18,
            cameraConstraint: CameraConstraint.containCenter(
              bounds: LatLngBounds(
                const LatLng(-6.697788086491729, 135.62482150691713),
                const LatLng(-31.324481038082332, 162.0974699871303)),
              ),
            interactionOptions: const InteractionOptions(flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'xyz.qldfire.app',
              maxNativeZoom: 18,
            ),
            GestureDetector(
              // TODO: Replace icon
              onTap: () {
                final LayerHitResult? hitResult = hitNotifier.value;
                if (hitResult == null) return;
                if (hitResult.hitValues.first is! Map) return;
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {    
                    // Potential improvement: Show data such as last update and number of vehicles en route and on scene.
                    return FireInfoDialog(fireData: hitResult.hitValues.first as Map);
                  }
                );
              },
              child: PolygonLayer(
                hitNotifier: hitNotifier,
                polygons: polygons,
              ),
            ),
            // PolygonLayer(
            //   hitNotifier: hitNotifier,
            //   polygons: polygons,
            // ),
            MarkerLayer(
              markers: points,
            ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution(
                  'OpenStreetMap contributors',
                  onTap: () => launchUrl(Uri.parse('https://openstreetmap.org/copyright')),
                ),
              ],
            ),
          ],
        );
      }
    );
  }

}