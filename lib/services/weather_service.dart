import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String condition;
  final String location;

  WeatherData({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.condition,
    required this.location,
  });

  factory WeatherData.fromOpenMeteo(Map<String, dynamic> json, String loc) {
    final current = json['current_weather'] ?? {};
    final temp = double.tryParse(current['temperature'].toString()) ?? 22.0;
    final wind = double.tryParse(current['windspeed'].toString()) ?? 12.0;
    final code = int.tryParse(current['weathercode'].toString()) ?? 0;

    String cond = 'Clear Sky';
    if (code == 1 || code == 2 || code == 3) cond = 'Partly Cloudy';
    if (code == 45 || code == 48) cond = 'Foggy';
    if (code >= 51 && code <= 67) cond = 'Drizzle / Light Rain';
    if (code >= 71 && code <= 77) cond = 'Snow Showers';
    if (code >= 80 && code <= 82) cond = 'Heavy Rain';
    if (code >= 95) cond = 'Thunderstorm';

    return WeatherData(
      temperature: temp,
      windSpeed: wind,
      weatherCode: code,
      condition: cond,
      location: loc,
    );
  }
}

class WeatherService extends ChangeNotifier {
  WeatherData? _currentWeather;
  bool _isLoading = false;
  String? _errorMessage;

  WeatherData? get currentWeather => _currentWeather;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  WeatherService() {
    fetchWeather();
  }

  Future<void> fetchWeather({double latitude = 31.5204, double longitude = 74.3587, String locationName = 'Lahore'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&current_weather=true',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentWeather = WeatherData.fromOpenMeteo(data, locationName);
      } else {
        _errorMessage = 'Weather API Error (${response.statusCode})';
      }
    } catch (e) {
      _errorMessage = 'Weather data unavailable: $e';
      if (kDebugMode) {
        debugPrint('Error fetching weather: $e');
      }
    } finally {
      // Fallback if network is offline
      _currentWeather ??= WeatherData(
        temperature: 24.5,
        windSpeed: 10.5,
        weatherCode: 1,
        condition: 'Partly Cloudy',
        location: locationName,
      );
      _isLoading = false;
      notifyListeners();
    }
  }
}
