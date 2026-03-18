import 'package:flutter/material.dart';
import '../generated/l10n/app_localizations.dart';
import '../models/profile_models.dart';
import '../screens/route_detail_screen.dart';
import '../utils/date_formatting.dart';
import '../widgets/grade_chip.dart';

class LikesList extends StatelessWidget {
  final List<UserLike> likes;
  final Map<String, String>? gradeColors;
  final VoidCallback? onRouteSelected;

  const LikesList({
    super.key,
    required this.likes,
    this.gradeColors,
    this.onRouteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: likes.length,
      itemBuilder: (context, index) {
        final like = likes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RouteDetailScreen(
                    routeId: like.routeId,
                  ),
                ),
              );
              // Call the callback when returning from route detail
              onRouteSelected?.call();
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Heart icon
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Route info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          like.routeName,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GradeChip(
                              grade: like.routeGrade,
                              gradeColorHex: gradeColors?[like.routeGrade],
                              fontSize: 12,
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                like.wallSection,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Date
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        formatRelativeDate(like.createdAt, l10n),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
