import 'dart:convert';
import 'package:searchable_listview/searchable_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app_proj/TabBar.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'CityDataItem.dart';
import 'SearchableCityList.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WEATHER',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Weather App'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedItemIndex = 0;
  final mode = ["Current", "Today", "Weekly"];
  var city = "";
  bool isCitySearched = false;
  WeatherItem? weatherItem;
  List<CityData> cities = [
    // Populate this list with your CityData objects
    CityData(name: "lyon", latitude: 45.74846, longitude: 4.84671, elevation: 173.0, featureCode: 'PPLA', countryCode: 'FR', country: "France", countryId: 0),
    CityData(name: "Paris", latitude: 45.74846, longitude: 4.84671, elevation: 173.0, featureCode: 'PPLA', countryCode: 'FR', country: "France", countryId: 0),
    CityData(name: "Tokyo", latitude: 45.74846, longitude: 4.84671, elevation: 173.0, featureCode: 'PPLA', countryCode: 'FR', country: "France", countryId: 0),
    CityData(name: "Londres", latitude: 45.74846, longitude: 4.84671, elevation: 173.0, featureCode: 'PPLA', countryCode: 'FR', country: "France", countryId: 0),
    // Add more CityData objects here
  ];

  CityData? cityData;

  TextEditingController controller = TextEditingController();
  
  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  Future<void> fetchCitiesData(String location) async{
  var baseUrl = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=$location&count=10&language=en&format=json');

  try{
    var response = await http.get(baseUrl);
    if (response.statusCode == 200){
      Map<String, dynamic> citiesList = jsonDecode(response.body);
      for (var city in citiesList.entries) {
        debugPrint("city: $city");
      }
      /*Map<String, dynamic> jsonResponse = json.decode(response.body);
      cityData = CityData.fromJson(jsonResponse);*/
    }
  }catch(error){
    debugPrint("Something wrong happened dude: $error");
  }
}
  
  Future<void> fetchData(Position position) async {
    var baseUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?'
        'latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&${mode[selectedItemIndex].toLowerCase()}=temperature_2m');

    try {
      var response = await http.get(baseUrl);
      debugPrint("response=${response.body}");
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode == 200){
        weatherItem = WeatherItem.fromJson(jsonResponse);
        debugPrint("WEATHER ITEM long: ${weatherItem?.longitude}");
        debugPrint("urlRequested: $baseUrl");
      }
    }catch(error){
      debugPrint("Petite erreur: $error");
    }
  }

  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () => {FocusScope.of(context).unfocus(),
      getPosition().then((pos) => debugPrint(pos.toString())).toString()
      },
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            bottom: AppBar(
              actions: [
                IconButton(onPressed: (){setState(() {
                  isCitySearched = false;
                  controller.text = "";
                });}, icon: const Icon(Icons.gps_fixed)),

              ],
              title: SearchableCityList(initialList: cities),/*AnimatedSearchBar(
                onFieldSubmitted: (_){
                  setState(() {
                    city = controller.text;
                    isCitySearched = true;
                    fetchCitiesData(city);
                  });
                 },
                onChanged: (_){},
                controller: controller,
              ),*/
              backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            ),

          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: SingleChildScrollView(
                child: SizedBox(
                  height: MediaQuery.of(context).size.height - 176,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children:[

                            Text(
                            mode[selectedItemIndex],
                            style:
                                const TextStyle(fontSize: 42, fontWeight: FontWeight.bold),
                          ),
                          isCitySearched ?
                            Text(city,
                              style:
                                const TextStyle(fontSize: 32),
                            ) :
                            FutureBuilder(future: getPosition(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting){
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                     return Text('[Error] ${snapshot.error}');
                                  }
                                  else{
                                    if (snapshot.hasData && snapshot.data != null){
                                      Position? pos = snapshot.data;
                                      if (pos != null)
                                        fetchData(pos);
                                      return Text("${pos!.latitude}, ${pos.longitude}",
                                      style: TextStyle(fontSize: 22),);
                                    }
                                    else {
                                      return const Text('Position unavailable');
                                    }
                                  }

                                })
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: WeatherBottomBar(
              onTap: (index) {
                setState(() {
                  selectedItemIndex = index;
                });
              },
              selectedItemIndex: selectedItemIndex)),
    );
  }

}

class WeatherItem {
  final double latitude;
  final double longitude;
  /*final Map<String, dynamic> hourlyUnits;
  final List<String> hourlyTime;
  final List<double> hourlyTemperature;*/

  WeatherItem({
    required this.latitude,
    required this.longitude,
    /*required this.hourlyUnits,
    required this.hourlyTime,
    required this.hourlyTemperature,*/
  });

  factory WeatherItem.fromJson(Map<String, dynamic> json) {
    return WeatherItem(
      latitude: json['latitude'],
      longitude: json['longitude'],
      /*hourlyUnits: json['hourly_units'],
      hourlyTime: List<String>.from(json['hourly']['time']),
      hourlyTemperature: List<double>.from(json['hourly']['temperature_2m']),*/
    );
  }

  Map<int, String> weatherCodes = {
    0: 'Clear sky',
    1: 'Mainly clear',
    2: 'Partly cloudy',
    3: 'Overcast',
    45: 'Fog',
    48: 'Depositing rime fog',
    51: 'Drizzle: Light intensity',
    53: 'Drizzle: Moderate intensity',
    55: 'Drizzle: Dense intensity',
    56: 'Freezing Drizzle: Light intensity',
    57: 'Freezing Drizzle: Dense intensity',
    61: 'Rain: Slight intensity',
    63: 'Rain: Moderate intensity',
    65: 'Rain: Heavy intensity',
    66: 'Freezing Rain: Light intensity',
    67: 'Freezing Rain: Heavy intensity',
    71: 'Snow fall: Slight intensity',
    73: 'Snow fall: Moderate intensity',
    75: 'Snow fall: Heavy intensity',
    77: 'Snow grains',
    80: 'Rain showers: Slight intensity',
    81: 'Rain showers: Moderate intensity',
    82: 'Rain showers: Violent intensity',
    85: 'Snow showers: Slight intensity',
    86: 'Snow showers: Heavy intensity',
    95: 'Thunderstorm: Slight or moderate',
    96: 'Thunderstorm with slight hail',
    99: 'Thunderstorm with heavy hail',
  };
}


