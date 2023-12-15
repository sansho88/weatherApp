import 'dart:ffi';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {

  final List<String> times;
  List<double> temperatures;
  List<double> minTempsList;
  List<double> maxTempsList;

  LineChartSample2({
    super.key,
    required this.times,
    this.temperatures = const [],
    this.minTempsList = const [],
    this.maxTempsList = const []
  });

  @override
  State<LineChartSample2> createState() => _LineChartSample2State(times, temperatures, minTempsList, maxTempsList);
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];
  final List<String> times;
  List<double>? temperatures;
  List<double>? minTempsList;
  List<double>? maxTempsList;

  _LineChartSample2State(this.times, this.temperatures, this.minTempsList, this.maxTempsList);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        AspectRatio(
          aspectRatio: 1.70,
          child: Padding(
            padding: const EdgeInsets.only(
              right: 18,
              left: 12,
              top: 24,
              bottom: 12,
            ),
            child: LineChart(
             mainData(),
            ),
          ),
        ),
      ],
    );
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    final indexTime = value.toInt();
    if (indexTime % 3 == 0)
      text = Text(times.elementAt(indexTime), style: style,);
    else
      text = const Text('', style: style);

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: text,
    );
  }

  List<double> calculateTemperatureScale(double minTemperature, double maxTemperature, int divisions) {
    List<double> scaleValues = [];
    double interval = (maxTemperature - minTemperature) / (divisions - 1);

    for (int i = 0; i < divisions; i++) {
      scaleValues.add(minTemperature + (interval * i));
    }

    return scaleValues;
  }

  List<FlSpot> getSpots(List<double> tempList){
    List<FlSpot> result = [];
    int i = 0;

    for (var value in times) { //fixme: quand Weekly (donc temperatures == empty): times = dates et non pas xxH00...
      String time;
      if (times.length > 7) {
        time = value.substring(0, 2);
        double timeDouble = double.parse(time);
        result.add(FlSpot(timeDouble, tempList.elementAt(timeDouble.toInt())));

      } else {
        time = (i).toString();
        print("TEMPLIST==>${tempList.toString()}");
        result.add(FlSpot(i.toDouble(), tempList.elementAt(i)));

        i++;
      }
      print("i ==>${time}");
      }
    return result;
  }
  
  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    var tempList = temperatures?.toList();
    var minTemp ;
    var maxTemp;

    if (tempList!.isNotEmpty) {
      tempList.sort((a, b) => min(a.toInt(), b.toInt()));
      minTemp = tempList.first;
      maxTemp = tempList.last;
    } else
      {
        tempList = minTempsList;
        tempList!.sort((a, b) => min(a.toInt(), b.toInt()));
        minTemp = tempList.first;
        tempList = maxTempsList;
        tempList!.sort((a, b) => max(a.toInt(), b.toInt()));
        maxTemp = tempList.first;
      }

    text = "${value.toInt()}°C";
    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    List<double> tempListA = temperatures!.isNotEmpty ? temperatures!.toList() : minTempsList!.toList() ;
    List<double> tempListB = temperatures!.isNotEmpty ? temperatures!.toList() : maxTempsList!.toList();
    tempListA.sort((a, b) => min(a.toInt(), b.toInt()));
    tempListB.sort((a, b) => max(a.toInt(), b.toInt()));
    final minTemp = (tempListA.first) - 2;
    final maxTemp = tempListB.first + 2;
    print("Temperatures=${temperatures.toString()}\nminTemp=>${minTemp}\nmaxTemp=>${maxTemp}");

    return LineChartData(
    
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 2,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: const Color(0xff37434d)),
      ),
      minX: 0,
      maxX: times.length.toDouble() - 1,
      minY: minTemp,
      maxY: maxTemp + 2,
      lineBarsData: [
        LineChartBarData(
          spots: getSpots(temperatures!.isNotEmpty ? temperatures!.toList() : minTempsList!.toList()),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
        (temperatures!.isEmpty)?
        LineChartBarData(
          spots: getSpots(maxTempsList!),
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ): LineChartBarData(),
      ],
    );
  }
}