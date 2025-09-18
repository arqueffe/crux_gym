class ClimbingWall {
  final ImageInfo imageInfo;
  final List<LaneShape> shapes;
  final int totalShapes;

  ClimbingWall({
    required this.imageInfo,
    required this.shapes,
    required this.totalShapes,
  });

  factory ClimbingWall.fromJson(Map<String, dynamic> json) {
    return ClimbingWall(
      imageInfo: ImageInfo.fromJson(json['image_info']),
      shapes: (json['shapes'] as List)
          .map((shape) => LaneShape.fromJson(shape))
          .toList(),
      totalShapes: json['total_shapes'],
    );
  }
}

class ImageInfo {
  final String filename;
  final int width;
  final int height;

  ImageInfo({
    required this.filename,
    required this.width,
    required this.height,
  });

  factory ImageInfo.fromJson(Map<String, dynamic> json) {
    return ImageInfo(
      filename: json['filename'],
      width: json['width'],
      height: json['height'],
    );
  }
}

class LaneShape {
  final String label;
  final String type;
  final List<List<int>> points;
  final int x1;
  final int y1;
  final int x2;
  final int y2;
  final int width;
  final int height;

  LaneShape({
    required this.label,
    required this.type,
    required this.points,
    required this.x1,
    required this.y1,
    required this.x2,
    required this.y2,
    required this.width,
    required this.height,
  });

  factory LaneShape.fromJson(Map<String, dynamic> json) {
    return LaneShape(
      label: json['label'],
      type: json['type'],
      points: (json['points'] as List)
          .map((point) => (point as List).cast<int>())
          .toList(),
      x1: json['x1'],
      y1: json['y1'],
      x2: json['x2'],
      y2: json['y2'],
      width: json['width'],
      height: json['height'],
    );
  }

  int get laneId => int.parse(label); // Lane label directly maps to lane ID
}
