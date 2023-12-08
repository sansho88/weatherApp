import 'package:flutter/material.dart';

class CityDataItem extends StatelessWidget {
  final String name;
  final double latitude;
  final double longitude;
  final double elevation;
  final String featureCode;
  final String countryCode;

  const CityDataItem({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.featureCode,
    required this.countryCode,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Name: $name'),
            ),
            ListTile(
              title: Text('Latitude: $latitude'),
            ),
            ListTile(
              title: Text('Longitude: $longitude'),
            ),
            ListTile(
              title: Text('Elevation: $elevation'),
            ),
            ListTile(
              title: Text('Feature Code: $featureCode'),
            ),
            ListTile(
              title: Text('Country Code: $countryCode'),
            ),
          ],
        ),
      ),
    );
  }
}
