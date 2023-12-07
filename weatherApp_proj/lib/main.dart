import 'package:flutter/material.dart';
import 'package:weather_app_proj/TabBar.dart';
import 'package:animated_search_bar/animated_search_bar.dart';

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
  var location = "";
  TextEditingController controller = TextEditingController();

  onCitySearched(){
    location = controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: Text(widget.title),
            bottom: AppBar(
              actions: [
                IconButton(onPressed: (){onCitySearched();}, icon: const Icon(Icons.send))
              ],
              title: AnimatedSearchBar(
                onFieldSubmitted: onCitySearched(),
                onChanged: (_){},
                controller: controller,
              ),
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
                          Text(location,
                            style:
                              const TextStyle(fontSize: 32),
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
