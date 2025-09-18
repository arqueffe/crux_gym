import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/role_models.dart';
import '../providers/auth_provider.dart';

/// Service for handling role-related API calls
class RoleService {
  final String baseUrl;
  final AuthProvider authProvider;

  RoleService({
    required this.baseUrl,
    required this.authProvider,
  });

  /// Get all roles
  Future<List<Role>> getRoles() async {
    final response = await _makeRequest('GET', '/roles');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => Role.fromJson(json))
            .toList();
      }
    }

    throw Exception('Failed to load roles: ${response.statusCode}');
  }

  /// Create a new role
  Future<Role> createRole({
    required String name,
    required String slug,
    String? description,
    required List<String> capabilities,
  }) async {
    final body = json.encode({
      'name': name,
      'slug': slug,
      'description': description,
      'capabilities': capabilities,
    });

    final response = await _makeRequest('POST', '/roles', body: body);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return Role.fromJson(data['data']);
      }
    }

    throw Exception('Failed to create role: ${response.statusCode}');
  }

  /// Update an existing role
  Future<void> updateRole({
    required int roleId,
    String? name,
    String? description,
    List<String>? capabilities,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (capabilities != null) body['capabilities'] = capabilities;

    final response =
        await _makeRequest('PUT', '/roles/$roleId', body: json.encode(body));

    if (response.statusCode != 200) {
      throw Exception('Failed to update role: ${response.statusCode}');
    }
  }

  /// Delete a role
  Future<void> deleteRole(int roleId) async {
    final response = await _makeRequest('DELETE', '/roles/$roleId');

    if (response.statusCode != 200) {
      throw Exception('Failed to delete role: ${response.statusCode}');
    }
  }

  /// Get user's roles
  Future<List<UserRole>> getUserRoles(int userId) async {
    final response = await _makeRequest('GET', '/users/$userId/roles');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => UserRole.fromJson(json))
            .toList();
      }
    }

    throw Exception('Failed to load user roles: ${response.statusCode}');
  }

  /// Assign role to user
  Future<void> assignUserRole({
    required int userId,
    required int roleId,
  }) async {
    final body = json.encode({
      'role_id': roleId,
    });

    final response =
        await _makeRequest('POST', '/users/$userId/roles', body: body);

    if (response.statusCode != 200) {
      throw Exception('Failed to assign role: ${response.statusCode}');
    }
  }

  /// Remove role from user
  Future<void> removeUserRole({
    required int userId,
    required int roleId,
  }) async {
    final response =
        await _makeRequest('DELETE', '/users/$userId/roles/$roleId');

    if (response.statusCode != 200) {
      throw Exception('Failed to remove role: ${response.statusCode}');
    }
  }

  /// Get current user's roles
  Future<List<UserRole>> getCurrentUserRoles() async {
    final response = await _makeRequest('GET', '/auth/roles');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return (data['data'] as List)
            .map((json) => UserRole.fromJson(json))
            .toList();
      }
    }

    throw Exception(
        'Failed to load current user roles: ${response.statusCode}');
  }

  /// Get current user's capabilities
  Future<List<String>> getCurrentUserCapabilities() async {
    final response = await _makeRequest('GET', '/auth/capabilities');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return List<String>.from(data['data']);
      }
    }

    throw Exception(
        'Failed to load current user capabilities: ${response.statusCode}');
  }

  /// Check if current user has a specific capability
  Future<bool> userHasCapability(String capability) async {
    try {
      final capabilities = await getCurrentUserCapabilities();
      return capabilities.contains(capability);
    } catch (e) {
      return false;
    }
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getUsers() async {
    final response = await _makeRequest('GET', '/users');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
    }

    throw Exception('Failed to load users: ${response.statusCode}');
  }

  /// Change user role (admin only)
  Future<void> changeUserRole({
    required int userId,
    required String roleSlug,
  }) async {
    final body = json.encode({
      'role_slug': roleSlug,
    });

    final response =
        await _makeRequest('PUT', '/users/$userId/role', body: body);

    if (response.statusCode != 200) {
      final data = json.decode(response.body);
      throw Exception(
          'Failed to change user role: ${data['message'] ?? response.statusCode}');
    }
  }

  /// Make HTTP request with authentication headers
  Future<http.Response> _makeRequest(String method, String endpoint,
      {String? body}) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      ...authProvider.getAuthHeaders(),
    };

    http.Response response;

    switch (method.toUpperCase()) {
      case 'GET':
        response = await http.get(uri, headers: headers);
        break;
      case 'POST':
        response = await http.post(uri, headers: headers, body: body);
        break;
      case 'PUT':
        response = await http.put(uri, headers: headers, body: body);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: headers);
        break;
      default:
        throw Exception('Unsupported HTTP method: $method');
    }

    return response;
  }
}
