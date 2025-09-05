import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/route_provider.dart';

class FilterBar extends StatelessWidget {
  const FilterBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border(
              bottom: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Wall Section',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      value: routeProvider.selectedWallSection,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Sections'),
                        ),
                        ...routeProvider.wallSections.map(
                          (section) => DropdownMenuItem<String>(
                            value: section,
                            child: Text(section),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        routeProvider.setWallSectionFilter(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Grade',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      value: routeProvider.selectedGrade,
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('All Grades'),
                        ),
                        ...routeProvider.grades.map(
                          (grade) => DropdownMenuItem<String>(
                            value: grade,
                            child: Text(grade),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        routeProvider.setGradeFilter(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Lane',
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(),
                      ),
                      value: routeProvider.selectedLane,
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Lanes'),
                        ),
                        ...routeProvider.lanes.map(
                          (lane) => DropdownMenuItem<int>(
                            value: lane.number,
                            child: Text(lane.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        routeProvider.setLaneFilter(value);
                      },
                    ),
                  ),
                ],
              ),
              if (routeProvider.selectedWallSection != null ||
                  routeProvider.selectedGrade != null ||
                  routeProvider.selectedLane != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton.icon(
                    onPressed: () => routeProvider.clearFilters(),
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear Filters'),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
