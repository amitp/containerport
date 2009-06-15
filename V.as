// Utility functions related to points and vectors

package {
  import flash.geom.*;
  
  public class V {
    // Multiply a vector by a scalar
    public static function scale(v:Point, k:Number):Point {
      return new Point(v.x * k, v.y * k);
    }

    // Rotate vector to the left 90 degrees
    public static function left(v:Point):Point {
      return new Point(v.y, -v.x);
    }

    // Rotate vector to the right 90 degrees
    public static function right(v:Point):Point {
      return new Point(-v.y, v.x);
    }

    // Intersection of two lines, represented as point+vector.
    public static function intersection(p:Point, u:Point,
                                        q:Point, v:Point):Point {
      var v_cross_u:Number = v.x*u.y - v.y*u.x;
      if (Math.abs(v_cross_u) <= 1e-4) {
        // Lines are parallel, or close to it, so use the midpoint
        return Point.interpolate(p, q, 0.5);
      }
      
      // Lines are not parallel, so compute the intersection, using the algorithm on
      // http://geometryalgorithms.com/Archive/algorithm_0104/algorithm_0104B.htm
      var w:Point = p.subtract(q);
      var v_cross_w:Number = v.x*w.y - v.y*w.x;
      var s:Number = -v_cross_w / v_cross_u;
      return new Point(p.x + u.x * s, p.y + u.y * s);
    }
  }
}
