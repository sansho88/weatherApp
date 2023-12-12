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


