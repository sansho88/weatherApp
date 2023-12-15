import 'dart:ffi';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class LineChartSample2 extends StatefulWidget {
  const LineChartSample2({super.key, required this.times, required this.temperatures});
  final List<String> times;
  final List<double> temperatures;


  @override
  State<LineChartSample2> createState() => _LineChartSample2State(times, temperatures);
}

class _LineChartSample2State extends State<LineChartSample2> {
  List<Color> gradientColors = [
    Colors.cyan,
    Colors.blue,
  ];
  final List<String> times;
  final List<double> temperatures;

  _LineChartSample2State(this.times, this.temperatures);

  bool showAvg = false;


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
              /*showAvg ? avgData() :*/ mainData(),
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

  List<FlSpot> getSpots(){
    List<FlSpot> result = [];
    for (var value in times) {
      String time = value.substring(0, 2);
      double timeDouble = double.parse(time);
      result.add(FlSpot(timeDouble, temperatures.elementAt(timeDouble.toInt())));
    }

    return result;
  }


  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    String text;
    var tempList = temperatures.toList();
    tempList.sort((a, b) => min(a.toInt(), b.toInt()));
    final minTemp = tempList.first - 2;
    final maxTemp = tempList.last + 2;
    var listScales = calculateTemperatureScale(minTemp, maxTemp, 7);
    var spots = getSpots();


    switch ((value.toInt() / tempList.length * 100).toInt()) {
      case 0:
        text = "${minTemp.toInt() - 2}°C";
        break;
      case 12:
        text = "${listScales.elementAt(1).toInt()}°C";
        break;
      case 29:
        text = "${listScales.elementAt(2).toInt()}°C";
        break;
      case 45:
        text = "${listScales.elementAt(3).toInt()}°C";
        break;
      case 58:
        text = "${listScales.elementAt(4).toInt()}°C";
        break;
      case 70:
        text = "${listScales.elementAt(5).toInt()}°C";
        break;
      case 83:
        text = "${listScales.elementAt(6).toInt()}°C";
        break;
      case 100:
        text = "${(maxTemp + 2).toInt()}°C";
        break;
      default:
        return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.left);
  }

  LineChartData mainData() {
    var spots = getSpots();
    var tempList = temperatures.toList();
    tempList.sort((a, b) => min(a.toInt(), b.toInt()));
    final minTemp = tempList.first - 2;
    final maxTemp = tempList.last + 2;

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 1,
        verticalInterval: 1,
        getDrawingHorizontalLine: (value) {
          return const FlLine(
            color: Colors.indigo,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return const FlLine(
            color: Colors.blue,
            strokeWidth: 1,
          );
        },
      ),
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
            interval: 1,
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
          spots: getSpots(),
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 5,
          isStrokeCapRound: true,
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
      ],
    );
  }
}