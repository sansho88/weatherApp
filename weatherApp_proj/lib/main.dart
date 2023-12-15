import 'dart:convert';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:weather_app_proj/TabBar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'CityDataItem.dart';
import 'WeatherItem.dart';


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
  var citySelected = "";
  late List<CityDataItem> cityDataList;
  bool isCitySearched = false;
  WeatherItem? weatherItem;
  CityDataItem? cityDataItem;
  Position? position;

  TextEditingController controller = TextEditingController();

  Future<Position> getPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List<CityDataItem>> fetchCitiesData(String search) async {
    final String apiUrl = 'https://geocoding-api.open-meteo.com/v1/search?name=$search&count=10&language=fr&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data['results'];
       cityDataList = results.map((json) => CityDataItem.fromJson(json)).toList();
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

  Future<WeatherItem?> fetchDataMeteoFromLocation(Position? position) async {
    if (position == null)
      return null;
    var baseUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?'
        'latitude=${position.latitude}'
        '&longitude=${position.longitude}'
        '&current=temperature_2m,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&timezone=Europe%2FBerlin');

    try {
      var response = await http.get(baseUrl);
      debugPrint("response=${response.body}");
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode == 200){
        weatherItem = WeatherItem.fromJson(jsonResponse);
        return weatherItem!;
      }
    }catch(error){
      debugPrint("[fetchDataMeteoFromLocation] Petite erreur: $error");
    }
    return null;
  }

  Future<WeatherItem?> fetchDataMeteoFromCity(CityDataItem cityDataItem) async {
    var baseUrl = Uri.parse('https://api.open-meteo.com/v1/forecast?'
        'latitude=${cityDataItem.latitude}'
        '&longitude=${cityDataItem.longitude}'
        '&current=temperature_2m,weather_code,wind_speed_10m'
        '&hourly=temperature_2m,weather_code,wind_speed_10m'
        '&daily=weather_code,temperature_2m_max,temperature_2m_min'
        '&timezone=Europe%2FBerlin');

    try {
      var response = await http.get(baseUrl);
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      if (response.statusCode == 200){
        weatherItem = WeatherItem.fromJson(jsonResponse);
        return weatherItem;
      }
    }catch(error){
      debugPrint("[fetchDataMeteoFromCity] Petite erreur: $error");
    }
    return null;
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
                SizedBox(width: 350, height: 52,
                  child:
                  TypeAheadField<CityDataItem>(
                    suggestionsCallback: (search) async {
                      if (search.isNotEmpty) {
                        return await fetchCitiesData(search);
                      } else {
                        return [];
                      }
                    },
                    builder: (context, controller, focusNode) {
                      return TextField(
                        onSubmitted: (_) {cityDataItem = cityDataList.first;
                        citySelected = "${cityDataItem!.name}\n${cityDataItem!.admin1}, ${cityDataItem!.country}";
                        fetchDataMeteoFromCity(cityDataItem!);
                        },
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
                          subtitle:Text("${city.countryCode}, ${city.admin1}, ${city.country}"),
                        );
                    },
                    onSelected: (city) {
                      cityDataItem = city;
                      citySelected = "${city.name}\n${city.admin1}, ${city.country}";
                      isCitySearched = true;
                      fetchDataMeteoFromCity(city);
                      position = null;
                      FocusScope.of(context).unfocus();
                      /* print("WEATHER ITEM FROM SELECTED CITY => $weatherItem");*/

                    },
                  ),
                ),
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
                          mainAxisAlignment: MainAxisAlignment.start,
                          children:[
                            isCitySearched ?
                            Text(citySelected,
                             style: const TextStyle(fontSize: 22),
                            ) :
                            (position != null && citySelected.isNotEmpty) ?  Text(citySelected,
                              style: const TextStyle(fontSize: 22),
                            ): FutureBuilder(future: getPosition(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting){
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('[Error] ${snapshot.error}');
                                  }
                                  else{
                                    if (snapshot.hasData && snapshot.data != null){
                                      var pos = snapshot.data;
                                      if (pos != null)
                                      {
                                        fetchDataMeteoFromLocation(pos);
                                        position = pos;
                                        placemarkFromCoordinates(pos.latitude, pos.longitude).then((value){
                                          var firstPlace = value.firstOrNull;
                                          citySelected = "${(firstPlace?.locality ?? "")}, ${(firstPlace!.administrativeArea ?? "")}, ${(firstPlace.country ?? "Somewhere")}";
                                        });
                                        //todo: transform pos to City
                                      }
                                      return Text(citySelected,
                                        style: const TextStyle(fontSize: 22),);
                                    }
                                    else {
                                      return const Text('Position unavailable');
                                    }
                                  }
                                }),
                            FutureBuilder(future: isCitySearched ? fetchDataMeteoFromCity(cityDataItem!) : fetchDataMeteoFromLocation(position),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting){
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    return Text('[Error] ${snapshot.error}');
                                  }
                                  else{
                                    if (snapshot.hasData && snapshot.data != null){
                                      WeatherItem? weather = snapshot.data;
                                      if (weather != null)
                                      {
                                        switch(mode[selectedItemIndex]){
                                        /** The location (city name, region and country).
                                            • The current temperature (in Celsius).
                                            • The current weather description (cloudy, sunny, rainy, etc.).
                                            • the current wind speed (in km/h).*/
                                          case "Current": return Column(
                                            children: [
                                              Text("${weatherItem!.current["temperature_2m"]}°C, ${weather.weatherCodes[weather.weather_code]}",),
                                              Text("WIND:${weather.current["wind_speed_10m"]}m/s"),
                                            ],
                                          );

                                        /** The location (city name, region and country).
                                            • The list of the weather for the day with the following data:
                                            ◦ The hours.
                                            ◦ The temperatures by hours.
                                            ◦ The weather description (cloudy, sunny, rainy, etc.) by hours.
                                            ◦ The wind speed (in km/h) by hours.*/
                                          case "Today":
                                            List<String> days = [];
                                            List<String> hours = [];
                                            List<double> temperatures = [];
                                            List<int> weatherCodes = [];
                                            List<double> windSpeeds = [];
                                            /** weatherItem!.hourly.values
                                             * First={date}T{hours}
                                             * Last=[temperatures]
                                             * */
                                            for(var timeTemps in weatherItem!.hourly.entries){
                                              var key = timeTemps.key;
                                              switch(key){
                                                case "time":
                                                  for (var date in timeTemps.value){
                                                    var hourString = date.toString();
                                                    var stringSplitted = hourString.split("T");
                                                    var hour = stringSplitted[1];
                                                    var day = stringSplitted[0];
                                                    day = day.replaceAll('-', '/');
                                                    days.add(day);
                                                    hours.add(hour);
                                                    if (hours.length == 24) break;
                                                  }
                                                  break;
                                                case "temperature_2m":
                                                  for (var temp in timeTemps.value){
                                                    temperatures.add(temp as double);
                                                    if (temperatures.length == 24) break;
                                                  }
                                                  break;
                                                case "weather_code":
                                                  for (var codes in timeTemps.value){
                                                    weatherCodes.add(codes as int);
                                                    if (weatherCodes.length == 24) break;
                                                  }
                                                  break;
                                                case "wind_speed_10m":
                                                  for (var speeds in timeTemps.value){
                                                    windSpeeds.add(speeds as double);
                                                    if (windSpeeds.length == 24) break;
                                                  }
                                                  break;
                                              }
                                            }
                                            return SizedBox(
                                              height: MediaQuery.of(context).size.height / 7, // ou une hauteur spécifique
                                              child: ListView.builder(
                                                  itemCount: 24,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return Card(
                                                        color: Colors.grey[300],
                                                        elevation: 8.0,
                                                        margin: const EdgeInsets.all(3.0),
                                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                        child: Column( mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            Text("  ${days.elementAt(index)}  ", style: const TextStyle(color: Colors.white),),
                                                            Text(" ${hours.elementAt(index)} ",
                                                              style:  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.w700, color: Colors.white,
                                                              ),
                                                            ),
                                                            Text(getWeatherEmoji(weatherCodes.elementAt(index))),
                                                            Text('${temperatures.elementAt(index)}°C', style: const TextStyle(color: Colors.white),),
                                                            Text('${windSpeeds.elementAt(index)}m/s', style: const TextStyle(color: Colors.white)),
                                                          ],
                                                        ),
                                                );

                                              }),
                                            );

                                        /**The location (city name, region and country).
                                            • The list of the weather for each day of the week with the following data:
                                              ◦ The date.
                                              ◦ The min and max temperatures of the day
                                              ◦ The weather description (cloudy, sunny, rainy, etc.).
                                         */
                                          case "Weekly":
                                            List<String> days = [];
                                            List<double> minTemperatures = [];
                                            List<double> maxTemperatures = [];
                                            List<int> weatherCodes = [];
                                            /** weatherItem!.daily.values
                                             * First={date}T{hours}
                                             * Last=[temperatures]
                                             * */
                                            for(var timeTemps in weatherItem!.daily.entries){
                                              var key = timeTemps.key;
                                              switch(key){
                                                case "time":
                                                  for (var date in timeTemps.value){
                                                    var hourString = date.toString();
                                                    var stringSplitted = hourString.split("T");
                                                    var day = stringSplitted[0];
                                                    day = day.replaceAll('-', '/');
                                                    days.add(day);
                                                  }
                                                  break;
                                                case "temperature_2m_max":
                                                  for (var temp in timeTemps.value){
                                                    maxTemperatures.add(temp as double);
                                                  }
                                                  break;
                                                case "temperature_2m_min":
                                                  for (var temp in timeTemps.value){
                                                    minTemperatures.add(temp as double);
                                                  }
                                                  break;
                                                case "weather_code":
                                                  for (var codes in timeTemps.value){
                                                    weatherCodes.add(codes as int);
                                                  }
                                                  break;
                                              }
                                            }
                                            return SizedBox(
                                              height: MediaQuery.of(context).size.height / 1.5,
                                              width: MediaQuery.of(context).size.width / 2.5,
                                              child: ListView.builder(
                                                  itemCount: 7,
                                                  scrollDirection: Axis.vertical,
                                                  itemBuilder: (BuildContext context, int index) {
                                                    return Card(
                                                      color: Colors.grey[300],
                                                      elevation: 8.0,
                                                      margin: const EdgeInsets.all(5.0),
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                                      child: Column( mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Text("  ${days.elementAt(index)}  ", style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                          Text(getWeatherEmoji(weatherCodes.elementAt(index)), style: const TextStyle(color: Colors.white, fontSize: 30)),
                                                          Text('${minTemperatures.elementAt(index)}°C / ${maxTemperatures.elementAt(index)}°C', style: const TextStyle(color: Colors.white, fontSize: 20),),
                                                        ],
                                                      ),
                                                    );

                                                  }),
                                            );

                                          default: return Text("Nothing to show");
                                        }
                                      }
                                    } else {
                                      return const Text('Weather unavailable');
                                    }
                                  }
                                  return const Text('Weather unavailable');
                              }
                            ),
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

  String getWeatherEmoji(int code){
    var result = '';
    if (code >= 45 && code <= 57)
      code = 45;
    else if (code >= 61 && code <= 67)
      code = 61;
    else if (code >= 71 && code <= 77)
      code = 71;
    else if (code >= 80 && code <= 86)
      code = 80;
    else if (code >= 95)
      code = 95;

    switch(code){
      case 0 : result = '☀️'; break;
      case 1 : result = '☀️'; break;
      case 2 : result = '☁️'; break;
      case 3 : result = '☁️'; break;
      case 45 : result = '🌫️'; break;
      case 61 : result = '🌧️'; break;
      case 71 : result = '❄️'; break;
      case 80 : result = '🚿'; break;
      case 95 : result = '⛈️'; break;
    }
    return result;
  }

}
