import 'package:flutter/material.dart';

class TabBar extends StatelessWidget{
   TabBar({super.key});

  final tabTexts = ["Currently", "Today", "Weekly"];

  Widget build(BuildContext context){
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(

          ),
        ),
      ),
    );

  }
}