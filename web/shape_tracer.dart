library shape_tracer;

import 'dart:html';
import 'dart:math';
import 'dart:typed_data';

part 'fill_search.dart';

List<Point> points = [];
List<Point> fillPath = null;
CanvasElement canvas;
CanvasRenderingContext2D context;

void main() {
  querySelector('#clear').onClick.listen(clear);
  querySelector('#fill').onClick.listen(fill);
  canvas = querySelector('canvas');
  context = canvas.getContext('2d');
  canvas.onMouseDown.listen(mouseDown);
}

void clear(_) {
  points = [];
  fillPath = null;
  redraw();
}

void fill(_) {
  if (fillPath != null) return;
  if (points.length > 12) {
    window.alert('the complexity of this algorithm is O(n!).' +
        ' You do not want to try this many points.');
    return;
  }
  if (points.length < 3) {
    window.alert('you must enter at least three points.');
    return;
  }
  fillPath = new FillSearch(points).findPath();
  if (fillPath == null) {
    window.alert('no shape could be filled.');
    return;
  }
  redraw();
}

void redraw() {
  context.clearRect(0, 0, canvas.width, canvas.height);
  
  if (fillPath != null) {
    print('drawing fill path');
    context.fillStyle = '#f00';
    context.beginPath();
    bool first = true;
    for (Point p in fillPath) {
      if (first) {
        first = false;
        context.moveTo(p.x, p.y);
      } else {
        context.lineTo(p.x, p.y);
      }
    }
    context.closePath();
    context.fill();
  }
  
  context.fillStyle = '#000';
  for (Point p in points) {
    context.beginPath();
    context.arc(p.x, p.y, 12, 0, PI * 2);
    context.fill();
  }
}

void mouseDown(MouseEvent evt) {
  Point p = evt.page - canvas.offset.topLeft;
  points.add(p * 2);
  fillPath = null;
  redraw();
}
