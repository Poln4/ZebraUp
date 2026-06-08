import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:hive_flutter/hive_flutter.dart';
import '../models/models.dart';

/// Fetches and caches daily weather snapshots from Open-Meteo.
/// One API call per (profile, date) per day, cached in Hive.
class WeatherService {
  static const _base = 'https://api.open-meteo.com/v1/forecast';

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  /// Returns today's WeatherDay for the given coords. Cached: subsequent calls
  /// within the same calendar day return immediately from Hive without hitting
  /// the network. Returns null if the network call fails AND nothing is cached.
  Future<WeatherDay?> getToday({required double lat, required double lng}) async {
    final today = DateTime.now();
    final key = _dateKey(today);
    final box = Hive.box('zebraBox');
    final cacheKey = 'weather:$key';

    // Check cache first.
    final cached = box.get(cacheKey);
    if (cached != null) {
      try {
        return WeatherDay.fromMap(Map<String, dynamic>.from(jsonDecode(cached)));
      } catch (_) {
        // Fall through to refetch if cache is corrupted.
      }
    }

    // Fetch today + yesterday so we can compute pressure delta.
    final yesterday = today.subtract(const Duration(days: 1));
    final url = Uri.parse('$_base?'
        'latitude=$lat&longitude=$lng'
        '&daily=temperature_2m_mean,relative_humidity_2m_mean,surface_pressure_mean'
        '&timezone=auto'
        '&start_date=${_dateKey(yesterday)}'
        '&end_date=$key');

    try {
      final resp = await http.get(url).timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final daily = data['daily'] as Map<String, dynamic>?;
      if (daily == null) return null;

      final temps = (daily['temperature_2m_mean'] as List?) ?? [];
      final hums = (daily['relative_humidity_2m_mean'] as List?) ?? [];
      final press = (daily['surface_pressure_mean'] as List?) ?? [];

      // Index 1 = today, index 0 = yesterday.
      double? at(List list, int i) =>
          (list.length > i && list[i] != null) ? (list[i] as num).toDouble() : null;

      final pressureToday = at(press, 1);
      final pressureYesterday = at(press, 0);
      final delta = (pressureToday != null && pressureYesterday != null)
          ? pressureToday - pressureYesterday
          : null;

      final weather = WeatherDay(
        dateKey: key,
        temperatureC: at(temps, 1),
        humidityPct: at(hums, 1),
        pressureHpa: pressureToday,
        pressureDeltaHpa: delta,
        fetchedAt: DateTime.now(),
      );

      // Cache for the rest of the day.
      await box.put(cacheKey, jsonEncode(weather.toMap()));
      return weather;
    } catch (_) {
      return null;
    }
  }

  /// Reads cached weather for a past date without hitting the network.
  /// Used to overlay past days on the calendar strip.
  WeatherDay? getCachedForDate(DateTime date) {
    final box = Hive.box('zebraBox');
    final cached = box.get('weather:${_dateKey(date)}');
    if (cached == null) return null;
    try {
      return WeatherDay.fromMap(Map<String, dynamic>.from(jsonDecode(cached)));
    } catch (_) {
      return null;
    }
  }
}