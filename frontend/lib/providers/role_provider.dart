import 'package:flutter/foundation.dart';
import '../models/role_models.dart';
import '../services/role_service.dart';
import '../providers/auth_provider.dart';

/// Provider for managing roles and user capabilities
class RoleProvider extends ChangeNotifier {
  late final RoleService _roleService;
  final AuthProvider _authProvider;

  RoleProvider({required AuthProvider authProvider})
      : _authProvider = authProvider {
    _roleService = RoleService(
      baseUrl: 'http://localhost/crux-climbing-gym/wp-json/crux/v1',
      authProvider: authProvider,
    );
  }

  List<Role> _roles = [];
  List<UserRole> _currentUserRoles = [];
  List<String> _currentUserCapabilities = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Role> get roles => _roles;
  List<UserRole> get currentUserRoles => _currentUserRoles;
  List<String> get currentUserCapabilities => _currentUserCapabilities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Load all roles (admin only)
  Future<void> loadRoles({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    try {
      _roles = await _roleService.getRoles();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading roles: $e');
    }
    _setLoading(false);
  }

  /// Load current user's roles and capabilities
  Future<void> loadCurrentUserRoles({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    try {
      _currentUserRoles = await _roleService.getCurrentUserRoles();
      _currentUserCapabilities =
          await _roleService.getCurrentUserCapabilities();
      _error = null;
    } catch (e) {
      _error = e.toString();
      print('Error loading current user roles: $e');
    }
    _setLoading(false);
  }

  /// Create a new role
  Future<bool> createRole({
    required String name,
    required String slug,
    String? description,
    required List<String> capabilities,
  }) async {
    _setLoading(true);
    try {
      final newRole = await _roleService.createRole(
        name: name,
        slug: slug,
        description: description,
        capabilities: capabilities,
      );

      _roles.add(newRole);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error creating role: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Update an existing role
  Future<bool> updateRole({
    required int roleId,
    String? name,
    String? description,
    List<String>? capabilities,
  }) async {
    _setLoading(true);
    try {
      await _roleService.updateRole(
        roleId: roleId,
        name: name,
        description: description,
        capabilities: capabilities,
      );

      // Update the local role
      final index = _roles.indexWhere((role) => role.id == roleId);
      if (index != -1) {
        final existingRole = _roles[index];
        _roles[index] = Role(
          id: existingRole.id,
          name: name ?? existingRole.name,
          slug: existingRole.slug,
          description: description ?? existingRole.description,
          capabilities: capabilities ?? existingRole.capabilities,
          isActive: existingRole.isActive,
          createdAt: existingRole.createdAt,
        );
      }

      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error updating role: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Delete a role
  Future<bool> deleteRole(int roleId) async {
    _setLoading(true);
    try {
      await _roleService.deleteRole(roleId);
      _roles.removeWhere((role) => role.id == roleId);
      _error = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error deleting role: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get user roles for a specific user
  Future<List<UserRole>> getUserRoles(int userId) async {
    try {
      return await _roleService.getUserRoles(userId);
    } catch (e) {
      _error = e.toString();
      print('Error getting user roles: $e');
      return [];
    }
  }

  /// Assign role to user
  Future<bool> assignUserRole({
    required int userId,
    required int roleId,
  }) async {
    try {
      await _roleService.assignUserRole(userId: userId, roleId: roleId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error assigning user role: $e');
      return false;
    }
  }

  /// Remove role from user
  Future<bool> removeUserRole({
    required int userId,
    required int roleId,
  }) async {
    try {
      await _roleService.removeUserRole(userId: userId, roleId: roleId);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error removing user role: $e');
      return false;
    }
  }

  /// Get all users (admin only)
  Future<List<Map<String, dynamic>>> getUsers() async {
    try {
      return await _roleService.getUsers();
    } catch (e) {
      _error = e.toString();
      print('Error getting users: $e');
      return [];
    }
  }

  /// Change user role (admin only)
  Future<bool> changeUserRole({
    required int userId,
    required String roleSlug,
  }) async {
    try {
      await _roleService.changeUserRole(userId: userId, roleSlug: roleSlug);
      return true;
    } catch (e) {
      _error = e.toString();
      print('Error changing user role: $e');
      return false;
    }
  }

  /// Check if current user has a specific capability
  bool hasCapability(String capability) {
    return _currentUserCapabilities.contains(capability);
  }

  /// Check if current user has any of the specified capabilities
  bool hasAnyCapability(List<String> capabilities) {
    return capabilities.any((capability) => hasCapability(capability));
  }

  /// Check if current user has all of the specified capabilities
  bool hasAllCapabilities(List<String> capabilities) {
    return capabilities.every((capability) => hasCapability(capability));
  }

  /// Get display name for a capability
  String getCapabilityDisplayName(String capability) {
    return Capability.getDisplayName(capability);
  }

  /// Get description for a capability
  String getCapabilityDescription(String capability) {
    return Capability.getDescription(capability);
  }

  /// Convenience methods for common permission checks
  bool get canManageSystem => hasCapability(Capability.manageSystem);
  bool get canManageUsers => hasCapability(Capability.manageUsers);
  bool get canManageRoles => hasCapability(Capability.manageRoles);
  bool get canCreateRoutes => hasCapability(Capability.createRoutes);
  bool get canEditRoutes => hasCapability(Capability.editRoutes);
  bool get canDeleteRoutes => hasCapability(Capability.deleteRoutes);
  bool get canViewAnalytics => hasCapability(Capability.viewAnalytics);
  bool get canManageWarnings => hasCapability(Capability.manageWarnings);
  bool get canModerateComments => hasCapability(Capability.moderateComments);

  /// Check if current user is admin level (has manage_users capability)
  bool get isAdmin => canManageUsers;

  /// Check if current user is super admin (has manage_system capability)
  bool get isSuperAdmin => canManageSystem;

  /// Get current user's highest role (by capability count)
  UserRole? get primaryRole {
    if (_currentUserRoles.isEmpty) return null;

    return _currentUserRoles.reduce((current, next) {
      return current.capabilities.length > next.capabilities.length
          ? current
          : next;
    });
  }

  /// Initialize role data when user logs in
  Future<void> initialize() async {
    await loadCurrentUserRoles();
  }

  /// Clear role data when user logs out
  void clear() {
    _roles.clear();
    _currentUserRoles.clear();
    _currentUserCapabilities.clear();
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
