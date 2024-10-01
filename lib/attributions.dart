import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataSourcesPage extends StatelessWidget {
  const DataSourcesPage({super.key});

  /*
    Attributions to include:
    - OpenStreetMaps
    - QFES

  */

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;

    return ListView(
      children: [
        Card(
          child: ExpansionTile(
            title: const Text("OpenStreetMap"),
            subtitle: const Text("Map | used under ODbL"),
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    text: TextSpan(
                      style: textStyle, 
                      text: "Map data and tiles originates from OpenStreetMap"
                            "which is licensed under the Open Data License."
                            "More information is available at ",
                      children: [
                        TextSpan(
                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          text: "https://openstreetmap.org/copyright",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse("https://openstreetmap.org/copyright"))
                        )
                      ]
                    )
                  ),
                ),
              ), 
            ],
          ),
        ),
        Card(
          child: ExpansionTile(
            title: const Text("Queensland Fire Department"),
            subtitle: const Text("Active fire data | used under CC-BY-4.0"),
            children: [
              SizedBox(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: RichText(
                    text: TextSpan(
                      style: textStyle, 
                      text: "Current fire and controller burns information originates from "
                            "Queensland Fire Department (formerly Queensland Fire and "
                            "Emergency Services), and is used under the "
                            "Creative Commons Attribution 4.0 license. "
                            "More information is available on the ",
                      children: [
                        TextSpan(
                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                          text: "Queensland Open Data Portal",
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => launchUrl(Uri.parse("https://www.data.qld.gov.au/dataset/queensland-fire-and-rescue-current-bushfire-incidents/resource/0b2a4ad3-e82b-4096-b800-7c3ebcdd0078"))
                        )
                      ]
                    )
                  ),
                ),
              ), 
            ],
          ),
        ),
      ],
    );
  }
}