import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/climbing_wall_models.dart';

class ClimbingWallService {
  static const String _wallDataPath = 'assets/models/crux.json';

  static Future<ClimbingWall> loadWallData() async {
    try {
      final String jsonString = await rootBundle.loadString(_wallDataPath);
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      return ClimbingWall.fromJson(jsonData);
    } catch (e) {
      throw Exception('Failed to load climbing wall data: $e');
    }
  }
}
