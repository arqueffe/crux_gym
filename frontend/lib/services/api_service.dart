import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/route_models.dart';
import '../providers/auth_provider.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:5000/api';
  final AuthProvider authProvider;

  ApiService({required this.authProvider});

  // Get headers with authentication
  Map<String, String> get _headers => authProvider.getAuthHeaders();

  // Generic HTTP methods
  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return {
        'success': true,
        'data': json.decode(response.body),
      };
    } else {
      return {
        'success': false,
        'error': 'Request failed with status ${response.statusCode}',
      };
    }
  }

  // Routes
  Future<List<Route>> getRoutes(
      {String? wallSection, String? grade, int? lane}) async {
    var uri = Uri.parse('$baseUrl/routes');
    var queryParams = <String, String>{};

    if (wallSection != null) queryParams['wall_section'] = wallSection;
    if (grade != null) queryParams['grade'] = grade;
    if (lane != null) queryParams['lane'] = lane.toString();

    if (queryParams.isNotEmpty) {
      uri = Uri.parse('$baseUrl/routes').replace(queryParameters: queryParams);
    }

    final response = await http.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Route.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load routes');
    }
  }

  Future<Route> getRoute(int routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return Route.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load route');
    }
  }

  Future<Route> createRoute(Route route) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes'),
      headers: _headers,
      body: json.encode(route.toJson()),
    );
    if (response.statusCode == 201) {
      return Route.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create route');
    }
  }

  // Likes
  Future<Like> likeRoute(int routeId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/like'),
      headers: _headers,
    );
    if (response.statusCode == 201) {
      return Like.fromJson(json.decode(response.body));
    } else if (response.statusCode == 400) {
      throw Exception('Already liked');
    } else {
      throw Exception('Failed to like route');
    }
  }

  Future<void> unlikeRoute(int routeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId/unlike'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to unlike route');
    }
  }

  // Comments
  Future<Comment> addComment(int routeId, String content) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/comments'),
      headers: _headers,
      body: json.encode({
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
    String proposedGrade,
    String? reasoning,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/grade-proposals'),
      headers: _headers,
      body: json.encode({
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
    String warningType,
    String description,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/warnings'),
      headers: _headers,
      body: json.encode({
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
    int routeId, {
    int attempts = 1,
    bool flash = false,
    String? notes,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/ticks'),
      headers: _headers,
      body: json.encode({
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

  Future<void> untickRoute(int routeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId/ticks'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to untick route');
    }
  }

  Future<Map<String, dynamic>> getUserTick(int routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/ticks/me'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get tick status');
    }
  }

  // Add attempts to a route
  Future<Map<String, dynamic>> addAttempts(int routeId, int attempts,
      {String? notes}) async {
    final body = {
      'attempts': attempts,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/attempts'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to add attempts');
    }
  }

  // Mark a route as sent in a specific style
  Future<Map<String, dynamic>> markSend(int routeId, String sendType,
      {String? notes}) async {
    final body = {
      'send_type': sendType,
      if (notes != null && notes.trim().isNotEmpty) 'notes': notes.trim(),
    };

    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/send'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to mark send');
    }
  }

  // Utility
  Future<List<String>> getWallSections() async {
    final response = await http.get(
      Uri.parse('$baseUrl/wall-sections'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load wall sections');
    }
  }

  Future<List<String>> getGrades() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grades'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<String>();
    } else {
      throw Exception('Failed to load grades');
    }
  }

  Future<List<int>> getLanes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/lanes'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<int>();
    } else {
      throw Exception('Failed to load lanes');
    }
  }

  // Grade and Color utilities
  Future<List<Map<String, dynamic>>> getGradeDefinitions() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grade-definitions'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load grade definitions');
    }
  }

  Future<List<Map<String, dynamic>>> getHoldColors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/hold-colors'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load hold colors');
    }
  }

  Future<Map<String, String>> getGradeColors() async {
    final response = await http.get(
      Uri.parse('$baseUrl/grade-colors'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data.cast<String, String>();
    } else {
      throw Exception('Failed to load grade colors');
    }
  }

  // Project methods
  Future<Project> addProject(int routeId, {String? notes}) async {
    final response = await http.post(
      Uri.parse('$baseUrl/routes/$routeId/projects'),
      headers: _headers,
      body: json.encode({'notes': notes}),
    );
    if (response.statusCode == 201) {
      return Project.fromJson(json.decode(response.body));
    } else {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to add project');
    }
  }

  Future<void> removeProject(int routeId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/routes/$routeId/projects'),
      headers: _headers,
    );
    if (response.statusCode != 200) {
      final errorData = json.decode(response.body);
      throw Exception(errorData['error'] ?? 'Failed to remove project');
    }
  }

  Future<Map<String, dynamic>?> getProjectStatus(int routeId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/routes/$routeId/projects/me'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load project status');
    }
  }

  Future<List<Project>> getUserProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/projects'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Project.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load user projects');
    }
  }
}
