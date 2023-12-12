import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app_proj/TabBar.dart';
import 'package:animated_search_bar/animated_search_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'CityDataItem.dart';
import 'WeatherItem.dart';
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


  Future<List<CityDataItem>> fetchCitiesData(String search) async {
    final String apiUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$search&count=10&language=fr&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
        List<CityDataItem> cityDataList = results.map((json) => CityDataItem.fromJson(json)).toList();
        return cityDataList;
      } else {
        debugPrint('Request failed with status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('Error fetching data: $e');
      return [];
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

                                }),
                            /*SearchableCityList(initialList: cities),*/
                            TypeAheadField<CityDataItem>(
                              suggestionsCallback: (search) async {
                                if (search.isNotEmpty) {
                                  debugPrint("Search of $search initiated");
                                  return await fetchCitiesData(search);
                                } else {
                                  debugPrint("Nothing to search");
                                  return [];
                                }
                              },
                              builder: (context, controller, focusNode) {
                                return TextField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    autofocus: true,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        labelText: 'City'
                                    )
                                );
                              },
                              itemBuilder: (context, city) {
                                return ListTile(
                                  title: Text(city.name),
                                  subtitle: Text("${city.countryCode}, ${city.longitude}, ${city.latitude}"),
                                );
                              },
                              onSelected: (city) {
                                Navigator.of(context).push<void>(
                                  MaterialPageRoute(
                                    builder: (context) => CityDataItem(name: city.name,
                                      latitude: city.latitude,
                                      longitude: city.longitude,
                                      elevation: city.elevation,
                                      featureCode: city.featureCode,
                                      countryCode: city.countryCode,
                                      id: 0,
                                      admin1Id: 0,
                                      admin2Id: 0,
                                      admin3Id: 0,
                                      admin4Id: 0,
                                      timezone: '',
                                      population: 0,
                                      postcodes: [],
                                      countryId: 0,
                                      country: '',
                                      admin1: '',
                                      admin2: '',
                                      admin3: '',
                                      admin4: '',
                                    ),
                                  ),
                                );
                              },
                            )
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
