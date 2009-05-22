package {
  import flash.geom.Point;
  
  dynamic public class DragConstraint {
    // Generate a point from the underlying state
    public var fromValue:Function = null;

    // Generate the underlying state from a point
    public var toValue:Function = null;

    // Factory functions
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
  }
}
