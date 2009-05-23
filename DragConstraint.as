// DragConstraint is the adapter between the non-GUI model value and
// the GUI drag handle position.  See Draggable.as for more.

package {
  import flash.geom.Point;
  
  dynamic public class DragConstraint {
    // Generate a point from the underlying state
    public var fromValue:Function = null;

    // Generate the underlying state from a point
    public var toValue:Function = null;

    // Factory function: linear slider for integer value
    static public function Integer(base:Point, dir:Point,
                                   obj:*, prop:*,
                                   min:Number = Number.NEGATIVE_INFINITY,
                                   max:Number = Number.POSITIVE_INFINITY
                                   ):DragConstraint {
      var dc:DragConstraint = new DragConstraint();
      dc.fromValue = function():Point {
        var scale:Number = obj[prop];
        return base.add(new Point(scale*dir.x, scale*dir.y));
      };
      dc.toValue = function(p:Point):void {
        var v:Point = p.subtract(base);
        // Project v onto dir, and divide by dir's length
        var x:Number = (v.x * dir.x + v.y * dir.y) / (dir.x * dir.x + dir.y * dir.y);
        obj[prop] = Math.max(min, Math.min(max, Math.round(x)));
      };
      return dc;
    }

    // Factory function: rotary angle control
    static public function Angle(center:Point, radius:Number, angle:Number,
                                 obj:*, prop:*):DragConstraint {
      var dc:DragConstraint = new DragConstraint();
      dc.fromValue = function():Point {
        return center.add(Point.polar(radius, angle + obj[prop]));
      }
      dc.toValue = function(p:Point):void {
        p = p.subtract(center);
        var a:Number = Math.atan2(p.y, p.x) - angle;
        while (a < 0.0) a += 2*Math.PI;
        obj[prop] = a;
      }
      return dc;
    }
  }
}
