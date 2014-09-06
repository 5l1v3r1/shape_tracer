part of shape_tracer;

bool linesIntersect(Point a1, Point a2, Point b1, Point b2) {
  // bounding box heuristic
  Rectangle aBox = new Rectangle.fromPoints(a1, a2);
  Rectangle bBox = new Rectangle.fromPoints(b1, b2);
  if (!aBox.intersects(bBox)) return false;
  
  // use the inverse of a matrix to determine the intersection of the lines and
  // confirm that the intersection is within the segments
  Float32x4 matrix1 = new Float32x4(b1.x.toDouble(), b1.y.toDouble(),
      a1.x.toDouble(), a1.y.toDouble());
  Float32x4 matrix2 = new Float32x4(b2.x.toDouble(), b2.y.toDouble(),
      a2.x.toDouble(), a2.y.toDouble());
  Float32x4 matrix = matrix2 - matrix1;
  
  // invert matrix
  double determinant = matrix.x * matrix.w - matrix.y * matrix.z;
  if (determinant.abs() < 0.0001) {
    // parallel lines don't "intersect"
    return false;
  }
  matrix = matrix.scale(1 / determinant);
  matrix = new Float32x4(matrix.w, -matrix.y, -matrix.z, matrix.x);
  
  Point diff = a1 - b1;
  matrix *= new Float32x4(diff.x.toDouble(), diff.x.toDouble(),
      diff.y.toDouble(), diff.y.toDouble());
  double bScale = matrix.x + matrix.z;
  double aScale = -(matrix.y + matrix.w);
  if (bScale < 0.001 || aScale > 0.999) return false;
  if (aScale < 0.001 || bScale > 0.999) return false;
  return true;
}

class FillSearch {
  final List<Point> points;
  List<Point> _path;
  List<Point> _remaining;
  
  FillSearch(this.points);
  
  List<Point> findPath() {
    _path = new List.from(points.sublist(0, 1));
    _remaining = new List.from(points.sublist(1));
    if (!_search()) {
      return null;
    }
    return _path;
  }
  
  bool _search() {
    if (!_validatePath()) return false;
    if (_remaining.length == 0) return true;
    
    List oldRemaining = new List.from(_remaining);
    
    // use a distance-based heuristic to explore the closest points first
    _remaining.sort((Point p1, Point p2) {
      double d1 = _path.last.distanceTo(p1);
      double d2 = _path.last.distanceTo(p2);
      if (d1 < d2) return -1;
      else if (d1 == d2) return 0;
      else return 1;
    });
    
    for (int i = 0; i < _remaining.length; ++i) {
      Point p = _remaining[i];
      _remaining.removeAt(i);
      _path.add(p);
      if (_search()) return true;
      _path.removeLast();
      _remaining.insert(i, p);
    }
    
    _remaining = oldRemaining;
    return false;
  }
  
  bool _validatePath() {
    if (_path.length < 3) return true;
    for (int i = 0; i < _path.length - 1; ++i) {
      Point a1 = _path[i];
      Point a2 = _path[i + 1];
      for (int j = i + 1; j < _path.length; ++j) {
        Point b1 = _path[j];
        Point b2 = _path[(j + 1) % _path.length];
        if (linesIntersect(a1, a2, b1, b2)) {
          return false;
        }
      }
    }
    return true;
  }
}
