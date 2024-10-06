import 'package:firefinder/dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:firefinder/main.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math';

class FiresMap extends StatelessWidget {
  const FiresMap({
    super.key,
    required this.mapController,
    required this.screenSize
  });

  final MapController mapController;
  final Size screenSize;

  double calculatePolygonArea(List<dynamic> inCoords) {
    var coords = inCoords[0].map<List<double>>((item) {
      return (item as List<dynamic>).map<double>((innerItem) => innerItem.toDouble()).toList();
    }).toList();

    int n = coords.length;
    double area = 0.0;

    // Shoelace formula to calculate area in square degrees
    for (int i = 0; i < n - 1; i++) {
      area += coords[i][0] * coords[i + 1][1] - coords[i][1] * coords[i + 1][0];
    }
    area = 0.5 * area.abs();

    // Conversion to square kilometers
    double degToKm = 111.0;  // Conversion factor for degrees to km
    double averageLatitude = coords.map((c) => c[1]).reduce((a, b) => a + b) / n;
    double areaSqKm = area * pow(degToKm, 2) * cos(averageLatitude * pi / 180);

    return areaSqKm;
  }

  @override
  Widget build(BuildContext context) {
    var fires = context.watch<MyAppState>().fires;

    var hazardYellow = [251, 224, 50];
    var hazardOrange = [255, 121, 0];
    var hazardRed = [214, 0, 28];

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
                  child: switch (feature['properties']['WarningLevel']) {
                    "Advice" || "Information" => Image(image: AssetImage("assets/fires/yellow.png")),
                    "Watch and Act" => Image(image: AssetImage("assets/fires/orange.png")),
                    "Emergency Warning" => Image(image: AssetImage("assets/fires/red.png"),),
                    _ => Icon(Icons.local_fire_department, size: 30, color: Color.fromARGB(255, hazardOrange[0], hazardOrange[1], hazardOrange[2]),),
                  },
                  onTap: () {
                    showDialog(
                      context: context, 
                      builder: (BuildContext context) {
                        return FireInfoDialog(fireData: feature,);
                      }
                    );
                  },
                ),
              ));
            } else if (feature['geometry']['type'] == "Polygon") {
              // Add it to the polygon layer
              polygons.add(Polygon(
                points: [for (var i in feature['geometry']['coordinates'][0]) LatLng(i[1], i[0])],
                borderColor: switch (feature['properties']['WarningLevel']) {
                  "Advice" || "Information" => Color.fromARGB(255, hazardYellow[0], hazardYellow[1], hazardYellow[2]),
                  "Emergency Warning" => Color.fromARGB(255, hazardRed[0], hazardRed[1], hazardRed[2]),
                  _ => Color.fromARGB(255, hazardOrange[0], hazardOrange[1], hazardOrange[2])
                },
                borderStrokeWidth: 2,
                color: switch (feature['properties']['WarningLevel']) {
                  "Advice" || "Information" => Color.fromARGB(120, hazardYellow[0], hazardYellow[1], hazardYellow[2]),
                  "Emergency Warning" => Color.fromARGB(120, hazardRed[0], hazardRed[1], hazardRed[2]),
                  _ => Color.fromARGB(120, hazardOrange[0], hazardOrange[1], hazardOrange[2])
                },
                hitValue: feature
              ));

              if(feature['properties'].containsKey("Latitude")) {
                points.add(Marker(
                  point: LatLng(feature['properties']['Latitude'], feature['properties']['Longitude']),
                  child: GestureDetector(
                    child: switch (feature['properties']['WarningLevel']) {
                      "Advice" || "Information" => Image(image: AssetImage("assets/fires/yellow.png")),
                      "Watch and Act" => Image(image: AssetImage("assets/fires/orange.png")),
                      "Emergency Warning" => Image(image: AssetImage("assets/fires/red.png"),),
                      _ => Icon(Icons.local_fire_department, size: 30, color: Color.fromARGB(255, hazardOrange[0], hazardOrange[1], hazardOrange[2]),),
                    },
                    onTap: () {
                      showDialog(
                        context: context, 
                        builder: (BuildContext context) {
                          return FireInfoDialog(fireData: feature,);
                        }
                      );
                    },
                  ),
                ));
              }
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
              onTap: () {
                final LayerHitResult? hitResult = hitNotifier.value;
                if (hitResult == null) return;
                if (hitResult.hitValues.first is! Map) return;
                showDialog(
                  context: context, 
                  builder: (BuildContext context) {
                    if (hitResult.hitValues.length > 1) {
                      var emerZones = [], watchZones = [], adviceZones = [];
                      for (var hit in hitResult.hitValues) {
                        hit as Map;
                        switch (hit['properties']['WarningLevel']) {
                          case "Advice":
                          case "Information":
                            adviceZones.add(hit);
                            break;
                          case "Watch and Act":
                            watchZones.add(hit);
                            break;
                          case "Emergency Warning":
                            emerZones.add(hit);
                            break;
                        }
                      }

                      emerZones.sort((a, b) => (calculatePolygonArea(a['geometry']['coordinates']) - calculatePolygonArea(b['geometry']['coordinates'])).round());
                      watchZones.sort((a, b) => (calculatePolygonArea(a['geometry']['coordinates']) - calculatePolygonArea(b['geometry']['coordinates'])).round());
                      adviceZones.sort((a, b) => (calculatePolygonArea(a['geometry']['coordinates']) - calculatePolygonArea(b['geometry']['coordinates'])).round());
                      var zones = [...emerZones, ...watchZones, ...adviceZones];

                      return FireInfoDialog(fireData: zones.first);

                    } else {
                      return FireInfoDialog(fireData: hitResult.hitValues.first as Map);
                    }
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