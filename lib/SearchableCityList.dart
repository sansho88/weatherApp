import 'package:flutter/material.dart';
import 'package:searchable_listview/searchable_listview.dart';
import 'CityDataItem.dart';

class CityData {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final double elevation;
  final String featureCode;
  final String countryCode;
  final int admin1Id;
  final int admin2Id;
  final int admin3Id;
  final int admin4Id;
  final String timezone;
  final int population;
  final List<String> postcodes;
  final int countryId;
  final String country;
  final String admin1;
  final String admin2;
  final String admin3;
  final String admin4;

  CityData({
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
    required this.countryId,
    required this.country,
    this.admin1 = "",
    this.admin2 = "",
    this.admin3 = "",
    this.admin4 = "",
  });

  factory CityData.fromJson(Map<String, dynamic> json) {
    return CityData(
      id: json['id'],
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      elevation: json['elevation'],
      featureCode: json['feature_code'],
      countryCode: json['country_code'],
      admin1Id: json['admin1_id'] ?? 0,
      admin2Id: json['admin2_id'] ?? 0,
      admin3Id: json['admin3_id'] ?? 0,
      admin4Id: json['admin4_id'] ?? 0,
      timezone: json['timezone'],
      population: json['population'],
      postcodes: List<String>.from(json['postcodes']),
      countryId: json['country_id'],
      country: json['country'],
      admin1: json['admin1'] ?? "",
      admin2: json['admin2'] ?? "",
      admin3: json['admin3'] ?? "",
      admin4: json['admin4'] ?? "",
    );
  }
}

class SearchableCityList extends StatelessWidget {
  final List<CityData> initialList;

  const SearchableCityList({super.key, required this.initialList});

  @override
  Widget build(BuildContext context) {
    return SizedBox(width: 300, height: 100,
      child: SearchableList<CityData>(
        initialList: initialList,
        itemBuilder: (CityData city) => CityDataItem(name: city.name,
          latitude: city.latitude,
          longitude: city.longitude,
          elevation: city.elevation,
          featureCode: city.featureCode,
          countryCode: city.countryCode,
          id: city.id,
          admin1Id: city.admin1Id,
          admin2Id: city.admin2Id,
          admin3Id: city.admin3Id,
          admin4Id: city.admin4Id,
          timezone: city.timezone,
          population: city.population,
          postcodes: city.postcodes,
          countryId: city.countryId,
          country: city.country,
          admin1: city.admin1,
          admin2: city.admin2,
          admin3: city.admin3,
          admin4: city.admin4,
        ),
        filter: (value) => initialList.where((element) => element.name.toLowerCase().contains(value)).toList(),
        emptyWidget: const Center(child: Text('No results')),
        inputDecoration: InputDecoration(
          labelText: 'Search City',
          fillColor: Colors.white,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
}

/*class CityDataItem extends StatelessWidget {
  final CityData city;

  const CityDataItem({required this.city});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(city.name),
      subtitle: Text('Latitude: ${city.latitude}, Longitude: ${city.longitude}'),
      // You can add more details here if needed
      onTap: () {
        // Action when a city is tapped
      },
    );
  }
}*/
