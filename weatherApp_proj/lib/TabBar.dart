import 'package:flutter/material.dart';

class TabBar extends StatelessWidget{
  const TabBar({super.key});

  final tabTexts = ["Currently", "Today", "Weekly"];

  Widget build(BuildContext context){
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(tabs: [
                                  Tab(icon: Icon(Icons.add),)
            ]),
          ),
        ),
      ),
    )

  }
}