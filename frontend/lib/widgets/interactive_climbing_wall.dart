import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/climbing_wall_models.dart';
import '../providers/route_provider.dart';
import '../services/climbing_wall_service.dart';

class InteractiveClimbingWall extends StatefulWidget {
  const InteractiveClimbingWall({super.key});

  @override
  State<InteractiveClimbingWall> createState() =>
      _InteractiveClimbingWallState();
}

class _InteractiveClimbingWallState extends State<InteractiveClimbingWall> {
  ClimbingWall? _wallData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWallData();
  }

  Future<void> _loadWallData() async {
    try {
      _wallData = await ClimbingWallService.loadWallData();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (_error != null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Text(
              'Error loading climbing wall: $_error',
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ),
      );
    }

    if (_wallData == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: Text('No wall data available'),
          ),
        ),
      );
    }

    return Consumer<RouteProvider>(
      builder: (context, routeProvider, child) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: MediaQuery.of(context).size.height *
                  0.3, // Max 30% of screen height
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate scale to fit both width and height, maintaining aspect ratio
                  final widthScale =
                      constraints.maxWidth / _wallData!.imageInfo.width;
                  final heightScale =
                      constraints.maxHeight / _wallData!.imageInfo.height;

                  // Use the smaller scale to ensure the image fits completely
                  final scale =
                      widthScale < heightScale ? widthScale : heightScale;

                  final scaledWidth = _wallData!.imageInfo.width * scale;
                  final scaledHeight = _wallData!.imageInfo.height * scale;

                  return Center(
                    child: SizedBox(
                      width: scaledWidth,
                      height: scaledHeight,
                      child: Stack(
                        children: [
                          // Background image
                          Container(
                            width: scaledWidth,
                            height: scaledHeight,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: const DecorationImage(
                                image: AssetImage('assets/models/crux.png'),
                                fit: BoxFit.contain, // Maintain aspect ratio
                              ),
                            ),
                          ),
                          // Interactive lane overlays
                          ..._wallData!.shapes.map((shape) {
                            final isSelected =
                                routeProvider.selectedLane == shape.laneId;
                            return _buildLaneOverlay(
                              shape,
                              scale, // Use the calculated scale
                              isSelected,
                              () =>
                                  _onLaneSelected(routeProvider, shape.laneId),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLaneOverlay(
    LaneShape shape,
    double scale,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // Convert polygon points to scaled coordinates
    final scaledPoints = shape.points
        .map((point) => Offset(point[0] * scale, point[1] * scale))
        .toList();

    return Positioned(
      left: shape.x1 * scale,
      top: shape.y1 * scale,
      width: shape.width * scale,
      height: shape.height * scale,
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: LanePainter(
            points: scaledPoints,
            isSelected: isSelected,
            laneId: shape.laneId,
            offset: Offset(shape.x1 * scale, shape.y1 * scale),
          ),
          size: Size(shape.width * scale, shape.height * scale),
        ),
      ),
    );
  }

  void _onLaneSelected(RouteProvider routeProvider, int laneId) {
    print('🔍 Interactive wall: Lane $laneId selected');
    print('🔍 Current selectedLane: ${routeProvider.selectedLane}');
    print('🔍 Available lanes: ${routeProvider.lanes.length} lanes');

    if (routeProvider.selectedLane == laneId) {
      print('🔍 Deselecting lane $laneId');
      routeProvider.setLaneFilter(null);
    } else {
      print('🔍 Selecting lane $laneId');
      routeProvider.setLaneFilter(laneId);
    }
  }
}

class LanePainter extends CustomPainter {
  final List<Offset> points;
  final bool isSelected;
  final int laneId;
  final Offset offset;

  LanePainter({
    required this.points,
    required this.isSelected,
    required this.laneId,
    required this.offset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isSelected ? Colors.blue.withOpacity(0.4) : Colors.transparent
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = isSelected ? Colors.blue : Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2 : 1;

    // Adjust points relative to the positioned widget
    final adjustedPoints = points
        .map((point) => Offset(point.dx - offset.dx, point.dy - offset.dy))
        .toList();

    if (adjustedPoints.isNotEmpty) {
      final path = Path();
      path.moveTo(adjustedPoints.first.dx, adjustedPoints.first.dy);

      for (int i = 1; i < adjustedPoints.length; i++) {
        path.lineTo(adjustedPoints[i].dx, adjustedPoints[i].dy);
      }
      path.close();

      // Fill the polygon
      canvas.drawPath(path, paint);

      // Draw the border
      canvas.drawPath(path, borderPaint);

      // Draw lane number if selected or on hover
      if (isSelected) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: laneId.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black,
                  offset: Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
          textDirection: TextDirection.ltr,
        );

        textPainter.layout();

        // Center the text in the lane
        final center = _getPolygonCenter(adjustedPoints);
        final textOffset = Offset(
          center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2,
        );

        textPainter.paint(canvas, textOffset);
      }
    }
  }

  Offset _getPolygonCenter(List<Offset> points) {
    double x = 0;
    double y = 0;

    for (final point in points) {
      x += point.dx;
      y += point.dy;
    }

    return Offset(x / points.length, y / points.length);
  }

  @override
  bool shouldRepaint(LanePainter oldDelegate) {
    return oldDelegate.isSelected != isSelected || oldDelegate.points != points;
  }
}
