import 'package:flutter/material.dart';
import '../models/route_models.dart' as models;

class RouteCard extends StatelessWidget {
  final models.Route route;
  final VoidCallback onTap;

  const RouteCard({
    super.key,
    required this.route,
    required this.onTap,
  });

  Color _getGradeColor(String grade) {
    if (grade.contains('V0') || grade.contains('V1')) return Colors.green;
    if (grade.contains('V2') || grade.contains('V3')) return Colors.yellow;
    if (grade.contains('V4') || grade.contains('V5')) return Colors.orange;
    if (grade.contains('V6') || grade.contains('V7')) return Colors.red;
    return Colors.purple;
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          route.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getGradeColor(route.grade),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                route.grade,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (route.color != null) ...[
                              const SizedBox(width: 8),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: _parseColor(route.color!),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.favorite,
                              color: Colors.red, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.likesCount}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.comment,
                              color: Colors.blue, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.commentsCount}'),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle,
                              color: Colors.green, size: 16),
                          const SizedBox(width: 4),
                          Text('${route.ticksCount}'),
                        ],
                      ),
                      if (route.warningsCount > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.warning,
                                color: Colors.orange, size: 16),
                            const SizedBox(width: 4),
                            Text('${route.warningsCount}'),
                          ],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.person, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Set by ${route.routeSetter}',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    route.wallSection,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              if (route.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  route.description!,
                  style: TextStyle(color: Colors.grey[700]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
