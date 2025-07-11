import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_models.dart' as models;
import '../providers/route_provider.dart';

class AddRouteScreen extends StatefulWidget {
  const AddRouteScreen({super.key});

  @override
  State<AddRouteScreen> createState() => _AddRouteScreenState();
}

class _AddRouteScreenState extends State<AddRouteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _routeSetterController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedGrade;
  String? _selectedWallSection;
  String? _selectedColor;

  final _grades = [
    'V0',
    'V1',
    'V2',
    'V3',
    'V4',
    'V5',
    'V6',
    'V7',
    'V8',
    'V9',
    'V10'
  ];
  final _wallSections = [
    'Overhang Wall',
    'Slab Wall',
    'Steep Wall',
    'Vertical Wall',
    'Cave Section',
    'Roof Section'
  ];
  final _colors = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple',
    'Pink',
    'Black',
    'White'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Route'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Consumer<RouteProvider>(
        builder: (context, routeProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route Information',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Route Name
                          TextFormField(
                            controller: _nameController,
                            decoration: const InputDecoration(
                              labelText: 'Route Name *',
                              border: OutlineInputBorder(),
                              helperText: 'Enter a creative name for the route',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Route name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Grade
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Grade *',
                              border: OutlineInputBorder(),
                              helperText: 'Select the difficulty grade',
                            ),
                            value: _selectedGrade,
                            items: _grades
                                .map((grade) => DropdownMenuItem(
                                      value: grade,
                                      child: Text(grade),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedGrade = value),
                            validator: (value) {
                              if (value == null) {
                                return 'Grade is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Route Setter
                          TextFormField(
                            controller: _routeSetterController,
                            decoration: const InputDecoration(
                              labelText: 'Route Setter *',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Name of the person who set this route',
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Route setter name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Wall Section
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Wall Section *',
                              border: OutlineInputBorder(),
                              helperText: 'Location of the route in the gym',
                            ),
                            value: _selectedWallSection,
                            items: _wallSections
                                .map((section) => DropdownMenuItem(
                                      value: section,
                                      child: Text(section),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedWallSection = value),
                            validator: (value) {
                              if (value == null) {
                                return 'Wall section is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Color (optional)
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(
                              labelText: 'Hold Color',
                              border: OutlineInputBorder(),
                              helperText: 'Color of the route holds (optional)',
                            ),
                            value: _selectedColor,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No specific color'),
                              ),
                              ..._colors.map((color) => DropdownMenuItem(
                                    value: color,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: _parseColor(color),
                                            shape: BoxShape.circle,
                                            border:
                                                Border.all(color: Colors.grey),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(color),
                                      ],
                                    ),
                                  )),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedColor = value),
                          ),
                          const SizedBox(height: 16),

                          // Description (optional)
                          TextFormField(
                            controller: _descriptionController,
                            decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder(),
                              helperText:
                                  'Optional description of the route style or features',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton(
                    onPressed: routeProvider.isLoading ? null : _submitRoute,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: routeProvider.isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              SizedBox(width: 8),
                              Text('Creating Route...'),
                            ],
                          )
                        : const Text(
                            'Create Route',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),

                  if (routeProvider.error != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Error: ${routeProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () => routeProvider.clearError(),
                            child: const Text('Dismiss'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _submitRoute() async {
    if (_formKey.currentState!.validate()) {
      final route = models.Route(
        id: 0, // Will be set by the server
        name: _nameController.text.trim(),
        grade: _selectedGrade!,
        routeSetter: _routeSetterController.text.trim(),
        wallSection: _selectedWallSection!,
        color: _selectedColor,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        gradeProposalsCount: 0,
        warningsCount: 0,
      );

      final routeProvider = context.read<RouteProvider>();
      final success = await routeProvider.createRoute(route);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Route created successfully!')),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Color _parseColor(String colorName) {
    switch (colorName.toLowerCase()) {
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _routeSetterController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
