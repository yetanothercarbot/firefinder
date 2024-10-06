import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'package:firefinder/map.dart';
import 'package:firefinder/attributions.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedPageIndex = 0;
  MapController mapController = MapController();

  @override
  Widget build(BuildContext context) {
    Widget page;
    String title;

    final ThemeData theme = Theme.of(context);
    final TextStyle textStyle = theme.textTheme.bodyMedium!;

    Future<PackageInfo> packageInfo = PackageInfo.fromPlatform();

    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "A visualiser for Queensland bushfire data."),
            TextSpan(style: textStyle, text: '.'),
          ],
        ),
      ),
    ];
    
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (selectedPageIndex) {
          case 0:
            page = FiresMap(mapController: mapController, screenSize: Size(constraints.maxWidth, constraints.maxHeight));
            title = "Fire Map Queensland";
            break;
          case 1:
            page = const DataSourcesPage();
            title = "Data Sources";
            break;
          default:
            throw UnimplementedError('No widget for $selectedPageIndex');
        }
        return Scaffold(
          appBar: AppBar(title: Text(title)),
          drawer: Drawer(
            child: SafeArea(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ListTile(
                    title: const Text('Current Fires'),
                    selected: selectedPageIndex == 0,
                    onTap: () {
                      setState(() {
                        selectedPageIndex = 0;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    title: const Text('Data Sources'),
                    selected: selectedPageIndex == 1,
                    onTap: () {
                      setState(() {
                        selectedPageIndex = 1;
                      });
                      Navigator.pop(context);
                    },
                  ),
                  FutureBuilder(
                    future: packageInfo,
                    builder: (context, snapshot) {
                      if (snapshot.data != null) {
                        return AboutListTile(
                          // icon: const Icon(Icons.info),
                          applicationIcon: Image(image: AssetImage('assets/icon/icon.png'), width: 60),
                          applicationName: snapshot.data!.appName,
                          applicationVersion: snapshot.data!.version,
                          applicationLegalese: 'Licensed under GPLv3',
                          aboutBoxChildren: aboutBoxChildren,
                        );
                      } else {
                        return AboutListTile(
                          applicationName: "Fire Map QLD",
                          applicationLegalese: 'Licensed under GPLv3',
                          aboutBoxChildren: aboutBoxChildren,
                        );
                      }
                    }
                  ),
                ],
              ),
            ),
          ),
          body: Row(
            children: [
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      }
    );
  }
}