import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/route_models.dart' as models;
import '../providers/route_provider.dart';
import '../utils/color_utils.dart';
import '../widgets/custom_app_bar.dart';
import '../generated/l10n/app_localizations.dart';

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

  int? _selectedGradeId;
  String? _selectedWallSection;
  int? _selectedLane;
  int? _selectedColorId;

  List<Map<String, dynamic>> _gradeDefinitions = [];
  List<Map<String, dynamic>> _holdColors = [];
  late List<String> _wallSections;

  @override
  void initState() {
    super.initState();
    _loadGradesAndColors();
    _loadLanes();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = AppLocalizations.of(context);
    _wallSections = [
      l10n.overhangWall,
      l10n.slabWall,
      l10n.steepWall,
      l10n.verticalWall,
      'Cave Section', // These don't seem to have translations yet
      'Roof Section'
    ];
  }

  Future<void> _loadGradesAndColors() async {
    final routeProvider = context.read<RouteProvider>();
    try {
      await routeProvider.loadGradeDefinitions();
      await routeProvider.loadHoldColors();
      setState(() {
        _gradeDefinitions = routeProvider.gradeDefinitions;
        _holdColors = routeProvider.holdColors;
      });
    } catch (e) {
      // Handle error - will use empty lists and show error
      print('Error loading grades and colors: $e');
    }
  }

  Future<void> _loadLanes() async {
    final routeProvider = context.read<RouteProvider>();
    try {
      await routeProvider.loadLanes();
    } catch (e) {
      print('Error loading lanes: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: l10n.addNewRoute,
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
                            l10n.routeInformation,
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 16),

                          // Route Name
                          TextFormField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: '${l10n.routeName} *',
                              border: const OutlineInputBorder(),
                              helperText: l10n.enterCreativeName,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.routeNameRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Grade
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: '${l10n.grade} *',
                              border: const OutlineInputBorder(),
                              helperText: l10n.selectDifficultyGrade,
                            ),
                            value: _selectedGradeId,
                            items: _gradeDefinitions
                                .map((gradeData) => DropdownMenuItem<int>(
                                      value: int.tryParse(
                                              gradeData['id'].toString()) ??
                                          (gradeData['id'] is int
                                              ? gradeData['id']
                                              : 0),
                                      child: Text(gradeData['grade'] as String),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedGradeId = value),
                            validator: (value) {
                              if (value == null) {
                                return l10n.gradeRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Route Setter
                          TextFormField(
                            controller: _routeSetterController,
                            decoration: InputDecoration(
                              labelText: '${l10n.routeSetter} *',
                              border: const OutlineInputBorder(),
                              helperText: l10n.nameOfPersonWhoSet,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return l10n.routeSetterRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Wall Section
                          DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: '${l10n.wallSection} *',
                              border: const OutlineInputBorder(),
                              helperText: l10n.locationOfRouteInGym,
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
                                return l10n.wallSectionRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Lane
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: '${l10n.lane} *',
                              border: const OutlineInputBorder(),
                              helperText: l10n.selectLaneNumber,
                            ),
                            value: _selectedLane,
                            items: routeProvider.lanes
                                .map((lane) => DropdownMenuItem(
                                      value: lane.id,
                                      child: Text(lane.name),
                                    ))
                                .toList(),
                            onChanged: (value) =>
                                setState(() => _selectedLane = value),
                            validator: (value) {
                              if (value == null) {
                                return l10n.laneRequired;
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Color (optional)
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: l10n.holdColor,
                              border: const OutlineInputBorder(),
                              helperText: l10n.colorOfRouteHolds,
                            ),
                            value: _selectedColorId,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                child: Text(l10n.noSpecificColor),
                              ),
                              ..._holdColors.map((colorData) {
                                final colorName = colorData['name'] as String;
                                final colorId =
                                    int.tryParse(colorData['id'].toString()) ??
                                        (colorData['id'] is int
                                            ? colorData['id']
                                            : 0);
                                final hexCode =
                                    colorData['hex_code'] as String?;
                                return DropdownMenuItem<int>(
                                  value: colorId,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color:
                                              ColorUtils.parseHexColor(hexCode),
                                          shape: BoxShape.circle,
                                          border:
                                              Border.all(color: Colors.grey),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(colorName),
                                    ],
                                  ),
                                );
                              }),
                            ],
                            onChanged: (value) =>
                                setState(() => _selectedColorId = value),
                          ),
                          const SizedBox(height: 16),

                          // Description (optional)
                          TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: l10n.routeDescription,
                              border: const OutlineInputBorder(),
                              helperText: l10n.optionalDescriptionRoute,
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
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 8),
                              Text(l10n.creatingRoute),
                            ],
                          )
                        : Text(
                            l10n.createRoute,
                            style: const TextStyle(fontSize: 16),
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
                            child: Text(l10n.dismiss),
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
        grade: _selectedGradeId!
            .toString(), // Store as string for now, but will be converted to grade_id in toJson
        routeSetter: _routeSetterController.text.trim(),
        wallSection: _selectedWallSection!,
        lane: _selectedLane!,
        color: _selectedColorId
            ?.toString(), // Store as string for now, but will be converted to hold_color_id in toJson
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: DateTime.now(),
        likesCount: 0,
        commentsCount: 0,
        gradeProposalsCount: 0,
        warningsCount: 0,
        ticksCount: 0,
        projectsCount: 0,
      );

      final routeProvider = context.read<RouteProvider>();
      final success = await routeProvider.createRoute(route);

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppLocalizations.of(context).routeCreatedSuccess)),
          );
          Navigator.pop(context);
        }
      }
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
