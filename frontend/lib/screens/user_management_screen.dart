import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/role_provider.dart';

/// Screen for managing user roles (admin only)
class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({Key? key}) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final roleProvider = context.read<RoleProvider>();
      _users = await roleProvider.getUsers();
    } catch (e) {
      _error = e.toString();
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _changeUserRole(int userId, String currentRole) async {
    final newRole = await _showRoleSelectionDialog(currentRole);
    if (newRole == null || newRole == currentRole) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final roleProvider = context.read<RoleProvider>();
      await roleProvider.changeUserRole(
        userId: userId,
        roleSlug: newRole,
      );

      // Update local user data
      final userIndex = _users.indexWhere((user) => user['id'] == userId);
      if (userIndex != -1) {
        _users[userIndex]['role_slug'] = newRole;
        _users[userIndex]['role_name'] = _getRoleDisplayName(newRole);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('User role updated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update user role: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<String?> _showRoleSelectionDialog(String currentRole) async {
    final roles = ['admin', 'route_setter', 'member'];

    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Role'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: roles.map((role) {
              return RadioListTile<String>(
                title: Text(_getRoleDisplayName(role)),
                subtitle: Text(_getRoleDescription(role)),
                value: role,
                groupValue: currentRole,
                onChanged: (value) {
                  Navigator.of(context).pop(value);
                },
              );
            }).toList(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  String _getRoleDisplayName(String roleSlug) {
    switch (roleSlug) {
      case 'admin':
        return 'Administrator';
      case 'route_setter':
        return 'Route Setter';
      case 'member':
        return 'Member';
      default:
        return roleSlug;
    }
  }

  String _getRoleDescription(String roleSlug) {
    switch (roleSlug) {
      case 'admin':
        return 'Full system access and user management';
      case 'route_setter':
        return 'Can create and manage routes';
      case 'member':
        return 'Basic access to view and interact with routes';
      default:
        return '';
    }
  }

  Color _getRoleColor(String roleSlug) {
    switch (roleSlug) {
      case 'admin':
        return Colors.red.shade700;
      case 'route_setter':
        return Colors.blue.shade700;
      case 'member':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Consumer<RoleProvider>(
        builder: (context, roleProvider, child) {
          // Check if user has permission
          if (!roleProvider.canManageUsers) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.security, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'You do not have permission to manage users.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          if (_error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red.shade300),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading users',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadUsers,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (_isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading users...'),
                ],
              ),
            );
          }

          if (_users.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No Users Found',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'No users are currently registered in the system.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadUsers,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                final roleSlug = user['role_slug'] ?? 'member';
                final roleName =
                    user['role_name'] ?? _getRoleDisplayName(roleSlug);

                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: _getRoleColor(roleSlug),
                      child: Text(
                        user['display_name']
                                ?.toString()
                                .substring(0, 1)
                                .toUpperCase() ??
                            'U',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      user['display_name'] ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (user['user_email'] != null)
                          Text(user['user_email']),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getRoleColor(roleSlug).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    _getRoleColor(roleSlug).withOpacity(0.3)),
                          ),
                          child: Text(
                            roleName,
                            style: TextStyle(
                              color: _getRoleColor(roleSlug),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _changeUserRole(user['id'], roleSlug),
                      tooltip: 'Change Role',
                    ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
