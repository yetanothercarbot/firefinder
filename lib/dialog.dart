import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class FireInfoDialog extends StatelessWidget {
  const FireInfoDialog({super.key, required this.fireData});

  final Map fireData;

  @override
  Widget build(BuildContext context) {
    var lastUpdated = DateTime.parse(fireData['properties']['ItemDateTimeLocal_ISO']);
    return AlertDialog(
      title: Text(fireData['properties']['WarningTitle']),
      content: SizedBox(
        height: 400,
        width: 350,
        child: ListView(children: [
          // Text("${fireData['properties']['Header']}\n${fireData['geometry']['type'] == 'Polygon' ? fireData['properties']['ShouldDo'].replaceAll('\r\n\r\n', '\n') : ''}"),
          Text("${fireData['properties']['Header']}"),
          Divider(),
          fireData['geometry']['type'] == 'Polygon' ? Text("${fireData['properties']['ShouldDo'].replaceAll('\r\n\r\n', '\n')}") : SizedBox.shrink(),
          fireData['geometry']['type'] == 'Polygon' ? Divider() : SizedBox.shrink(),
          Table(
            border: const TableBorder.symmetric(),
            children: <TableRow>[
              TableRow(
                children: [
                  const TableCell(child: Text("Location")),
                  TableCell(child: Text(fireData['properties']['Location']))
                ]
              ),
              TableRow(
                children: [
                  const TableCell(child: Text("Status")),
                  TableCell(child: Text(fireData['properties']['CurrentStatus']))
                ]
              ),
              TableRow(
                children: [
                  const TableCell(child: Text("Vehicles Assigned")),
                  TableCell(child: Text(fireData['properties']['VehiclesAssigned']))
                ]
              ),
              TableRow(
                children: [
                  const TableCell(child: Text("Vehicles On Route")),
                  TableCell(child: Text(fireData['properties']['VehiclesOnRoute']))
                ]
              ),
              TableRow(
                children: [
                  const TableCell(child: Text("Vehicles On Scene")),
                  TableCell(child: Text(fireData['properties']['VehiclesOnScene']))
                ]
              ),
            ],
          ),
          Text("\nResponse Time: ${timeago.format(lastUpdated)}")
        ]),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context, 'OK'),
          child: const Text('OK'),
        ),
      ],
    );
  }
}