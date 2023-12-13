class WeatherItem {
  final double latitude;
  final double longitude;
  final double generationTimeMs;
  final int utcOffsetSeconds;
  final String timezone;
  final String timezoneAbbreviation;
  final double elevation;
  final Map<String, String> currentUnits;
  final Map<String, dynamic> current;
  final Map<String, String> hourlyUnits;
  final Map<String, dynamic> hourly;
  final Map<String, dynamic> daily;
  final int weather_code;

  WeatherItem({
    required this.latitude,
    required this.longitude,
    required this.weather_code,
    required this.generationTimeMs,
    required this.utcOffsetSeconds,
    required this.timezone,
    required this.timezoneAbbreviation,
    required this.elevation,
    required this.currentUnits,
    required this.current,
    required this.hourlyUnits,
    required this.hourly,
    required this.daily,
  });

  factory WeatherItem.fromJson(Map<String, dynamic> json) {
    print("[WeatherItem] ${json}");
    return WeatherItem(
      latitude: json['latitude'],
      longitude: json['longitude'] ,
      weather_code: json['current']['weather_code']/*json['weather_code']*/,
      generationTimeMs: json['generationtime_ms'],
      utcOffsetSeconds: json['utc_offset_seconds'],
      timezone: json['timezone'] ?? "",
      timezoneAbbreviation: json['timezone_abbreviation'] ?? "",
      elevation: json['elevation'],
      currentUnits: Map<String, String>.from(json['current_units'] ?? {}),
      current: Map<String, dynamic>.from(json['current'] ?? {}),
      hourlyUnits: Map<String, String>.from(json['hourly_units'] ?? {}),
      hourly: Map<String, dynamic>.from(json['hourly'] ?? {}),
      daily: Map<String, dynamic>.from(json['daily'] ?? {}),
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


