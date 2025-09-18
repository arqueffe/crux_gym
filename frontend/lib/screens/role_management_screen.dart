import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/role_models.dart';
import '../providers/role_provider.dart';

class RoleManagementScreen extends StatefulWidget {
  const RoleManagementScreen({Key? key}) : super(key: key);

  @override
  State<RoleManagementScreen> createState() => _RoleManagementScreenState();
}

class _RoleManagementScreenState extends State<RoleManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final roleProvider = Provider.of<RoleProvider>(context, listen: false);
      roleProvider.loadRoles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Role Management'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<RoleProvider>(
        builder: (context, roleProvider, child) {
          if (roleProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (roleProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${roleProvider.error}',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => roleProvider.loadRoles(forceRefresh: true),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'System Roles',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showCreateRoleDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Create Role'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: roleProvider.roles.isEmpty
                      ? const Center(
                          child: Text(
                            'No roles found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: roleProvider.roles.length,
                          itemBuilder: (context, index) {
                            final role = roleProvider.roles[index];
                            return _buildRoleCard(context, role);
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRoleCard(BuildContext context, Role role) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        role.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role.slug,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () => _showEditRoleDialog(context, role),
                      icon: const Icon(Icons.edit),
                      tooltip: 'Edit Role',
                    ),
                    if (role.slug !=
                        'super_admin') // Prevent deleting super admin
                      IconButton(
                        onPressed: () => _showDeleteRoleDialog(context, role),
                        icon: const Icon(Icons.delete),
                        color: Colors.red,
                        tooltip: 'Delete Role',
                      ),
                  ],
                ),
              ],
            ),
            if (role.description != null && role.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                role.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            const SizedBox(height: 12),
            Text(
              'Capabilities (${role.capabilities.length}):',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: role.capabilities
                  .map((capability) => Chip(
                        label: Text(
                          Capability.getDisplayName(capability),
                          style: const TextStyle(fontSize: 12),
                        ),
                        backgroundColor: Colors.blue[100],
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoleDialog(BuildContext context) {
    _showRoleDialog(context, title: 'Create New Role');
  }

  void _showEditRoleDialog(BuildContext context, Role role) {
    _showRoleDialog(
      context,
      title: 'Edit Role',
      existingRole: role,
    );
  }

  void _showRoleDialog(
    BuildContext context, {
    required String title,
    Role? existingRole,
  }) {
    final nameController = TextEditingController(text: existingRole?.name);
    final slugController = TextEditingController(text: existingRole?.slug);
    final descriptionController =
        TextEditingController(text: existingRole?.description);
    final selectedCapabilities =
        Set<String>.from(existingRole?.capabilities ?? []);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(title),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Role Name',
                      hintText: 'e.g., Route Setter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: slugController,
                    enabled:
                        existingRole == null, // Only editable when creating
                    decoration: const InputDecoration(
                      labelText: 'Role Slug',
                      hintText: 'e.g., route_setter',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      hintText: 'Describe this role...',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Capabilities:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: SingleChildScrollView(
                      child: Column(
                        children: Capability.getAllCapabilities()
                            .map((capability) => CheckboxListTile(
                                  title: Text(
                                      Capability.getDisplayName(capability)),
                                  subtitle: Text(
                                    Capability.getDescription(capability),
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  value:
                                      selectedCapabilities.contains(capability),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      if (value == true) {
                                        selectedCapabilities.add(capability);
                                      } else {
                                        selectedCapabilities.remove(capability);
                                      }
                                    });
                                  },
                                  dense: true,
                                ))
                            .toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _saveRole(
                context,
                nameController.text,
                slugController.text,
                descriptionController.text,
                selectedCapabilities.toList(),
                existingRole,
              ),
              child: Text(existingRole == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  void _saveRole(
    BuildContext context,
    String name,
    String slug,
    String description,
    List<String> capabilities,
    Role? existingRole,
  ) async {
    if (name.isEmpty || slug.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and slug are required')),
      );
      return;
    }

    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    bool success;

    if (existingRole == null) {
      success = await roleProvider.createRole(
        name: name,
        slug: slug,
        description: description.isNotEmpty ? description : null,
        capabilities: capabilities,
      );
    } else {
      success = await roleProvider.updateRole(
        roleId: existingRole.id,
        name: name,
        description: description.isNotEmpty ? description : null,
        capabilities: capabilities,
      );
    }

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(existingRole == null
              ? 'Role created successfully'
              : 'Role updated successfully'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${roleProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showDeleteRoleDialog(BuildContext context, Role role) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Role'),
        content:
            Text('Are you sure you want to delete the role "${role.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteRole(context, role),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _deleteRole(BuildContext context, Role role) async {
    final roleProvider = Provider.of<RoleProvider>(context, listen: false);
    final success = await roleProvider.deleteRole(role.id);

    Navigator.of(context).pop();

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Role deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${roleProvider.error}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
