import 'package:flutter/material.dart';

class WeatherBottomBar extends StatelessWidget {
  final void Function(int) onTap;
  final int selectedItemIndex;

   WeatherBottomBar({super.key, required this.onTap, required this.selectedItemIndex});

  final tabTexts = ["Currently", "Today", "Weekly"];

  @override
  Widget build(BuildContext context){
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.access_alarm),
            label: "Current"),
        BottomNavigationBarItem(icon: Icon(Icons.today),
          label: "Today",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.next_week),
            label: "Weekly")
      ],
      onTap: onTap,
      currentIndex: selectedItemIndex,
      backgroundColor: Colors.transparent,
    );

  }
}

