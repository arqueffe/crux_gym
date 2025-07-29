import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_models.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';

  // Routes
  Future<List<Route>> getRoutes({String? wallSection, String? grade}) async {
    var uri = Uri.parse('$baseUrl/routes');
    var queryParams = <String, String>{};

    if (wallSection != null) queryParams['wall_section'] = wallSection;
    if (grade != null) queryParams['grade'] = grade;

    if (queryParams.isNotEmpty) {
      uri = Uri.parse('$baseUrl/routes').replace(queryParameters: queryParams);
    }

    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Route.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<Route> getRoute(int routeId) async {
    final response = await http.get(Uri.parse('$baseUrl/routes/$routeId'));
    if (response.statusCode == 200) {
      return Route.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<Route> createRoute(Route route) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(route.toJson()),
    );
    if (response.statusCode == 201) {
      return Route.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create route');
    }
  }

  // Likes
  Future<Like> likeRoute(int routeId, String userName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/like'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_name': userName}),
    );
    if (response.statusCode == 201) {
      return Like.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Already liked');
    } else {
      throw Exception('Failed to like route');
    }
  }

  Future<void> unlikeRoute(int routeId, String userName) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId/unlike'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'user_name': userName}),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unlike route');
    }
  }

  // Comments
  Future<Comment> addComment(
      int routeId, String userName, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/comments'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': userName,
        'content': content,
      }),
    );
    if (response.statusCode == 201) {
      return Comment.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add comment');
    }
  }

  // Grade Proposals
  Future<GradeProposal> proposeGrade(
    int routeId,
    String userName,
    String proposedGrade,
    String? reasoning,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/grade-proposals'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': userName,
        'proposed_grade': proposedGrade,
        'reasoning': reasoning,
      }),
    );
    if (response.statusCode == 201) {
      return GradeProposal.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to propose grade');
    }
  }

  // Warnings
  Future<Warning> addWarning(
    int routeId,
    String userName,
    String warningType,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/warnings'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': userName,
        'warning_type': warningType,
        'description': description,
      }),
    );
    if (response.statusCode == 201) {
      return Warning.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to add warning');
    }
  }

  // Ticks
  Future<Tick> tickRoute(
    int routeId,
    String userName, {
    int attempts = 1,
    bool flash = false,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/ticks'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'user_name': userName,
        'attempts': attempts,
        'flash': flash,
        'notes': notes,
      }),
    );
    if (response.statusCode == 201) {
      return Tick.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Route already ticked');
    } else {
      throw Exception('Failed to tick route');
    }
  }

  Future<void> untickRoute(int routeId, String userName) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId/ticks/$userName'),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to untick route');
    }
  }

  Future<Map<String, dynamic>> getUserTick(int routeId, String userName) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/ticks/$userName'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get tick status');
    }
  }

  // Utility
  Future<List<String>> getWallSections() async {
    final response = await http.get(Uri.parse('$baseUrl/wall-sections'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load wall sections');
    }
  }

  Future<List<String>> getGrades() async {
    final response = await http.get(Uri.parse('$baseUrl/grades'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load grades');
    }
  }
}
