import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';

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

    final List<Widget> aboutBoxChildren = <Widget>[
      const SizedBox(height: 24),
      RichText(
        text: TextSpan(
          children: <TextSpan>[
            TextSpan(
                style: textStyle,
                text: "Flutter is Google's UI toolkit for building beautiful, "
                    'natively compiled applications for mobile, web, and desktop '
                    'from a single codebase. Learn more about Flutter at '),
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
                  AboutListTile(
                    // icon: const Icon(Icons.info),
                    applicationIcon: const FlutterLogo(), // TODO: Replace
                    applicationName: 'Fire Map Qld',
                    applicationVersion: 'v1.0.0',
                    applicationLegalese: 'Licensed under GPLv3',
                    aboutBoxChildren: aboutBoxChildren,
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