import 'package:flutter/material.dart';

class CityDataItem extends StatelessWidget {
  int id;
  final String name;
  final double latitude;
  final double longitude;
  final double elevation;
  final String featureCode;
  final String countryCode;
  int admin1Id;
  int admin2Id;
  int admin3Id;
  int admin4Id;
  String timezone;
  final int population;
  List<String> postcodes;
  final int countryId;
  String country;
  String admin1;
  String admin2;
  String admin3;
  String admin4;

  CityDataItem({super.key,
     this.id = 0,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.elevation,
    required this.featureCode,
    required this.countryCode,
     this.admin1Id = 0,
     this.admin2Id = 0,
     this.admin3Id = 0,
     this.admin4Id = 0,
     this.timezone = "",
     this.population = 0,
     this.postcodes = const [""],
     this.countryId = 0,
    required this.country,
    required this.admin1,
     this.admin2 = "",
     this.admin3 = "",
     this.admin4 = "",
  });

  factory CityDataItem.fromJson(Map<String, dynamic> json) {
    return CityDataItem(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      latitude: json['latitude'] ?? 0.0,
      longitude: json['longitude'] ?? 0.0,
      elevation: json['elevation'] ?? 0.0,
      featureCode: json['feature_code'] ?? '',
      countryCode: json['country_code'] ?? '',
      admin1Id: json['admin1_id'] ?? 0,
      admin2Id: json['admin2_id'] ?? 0,
      admin3Id: json['admin3_id'] ?? 0,
      admin4Id: json['admin4_id'] ?? 0,
      timezone: json['timezone'] ?? '',
      population: json['population'] ?? 0,
      postcodes: List<String>.from(json['postcodes'] ?? []),
      countryId: json['country_id'] ?? 0,
      country: json['country'] ?? '',
      admin1: json['admin1'] ?? '',
      admin2: json['admin2'] ?? '',
      admin3: json['admin3'] ?? '',
      admin4: json['admin4'] ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: Text('Name: $name'),
            ),
            /*ListTile(
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
            ),*/
          ],
        ),
      ),
    );
  }
}
