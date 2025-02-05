import 'dart:convert';

import 'package:http/http.dart' as http;

class FireLocationApi {
  // late points;

  FireLocationApi();

  Future<Map<String, dynamic>> fetch() async {
    final response = await http.get(Uri.parse("https://publiccontent-gis-psba-qld-gov-au.s3.amazonaws.com/content/Feeds/BushfireCurrentIncidents/bushfireAlert.json"));
    return jsonDecode(response.body);
  }
}