import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:firefinder/ui.dart';
import 'package:firefinder/fire_locations_api.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
          title: 'SEQPrepare',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          ),
          home: const MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  FireLocationApi fireApi = FireLocationApi();
  late Future<Map<String, dynamic>> fires;
  
  @override
  MyAppState() {
    fires = fireApi.fetch();
  }
}