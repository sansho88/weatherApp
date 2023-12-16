import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final List<Widget> contentWidgets;

  const WeatherCard({
    required this.contentWidgets,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color(0x88FFFFFF),
      elevation: 8.0,
      margin: const EdgeInsets.all(5.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: contentWidgets.map((widget) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 0.2),
            child: widget,
          );
        }).toList(),
      ),
    );
  }
}
