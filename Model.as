// Model tracks values that can be exposed via the GUI. Model adapters
// convert values to another form.

// To build your own model, pass a getter and setter function to new Model().

// To get a reference to an object property, Model.ref(obj, prop).
// Note that this also works with arrays: Model.ref(array, index).

// To adapt the model to another situation, call an adapter function,
// which will return a new model.  For example, Model.ref(sprite,
// "x").clamped(0, 100) will clamp the x value to between 0 and 100
// (inclusive).

// Binary adapters are structured differently, where instead of
// base.mod() you call Model.mod(base1, base2). For example,
// Model.polar(base1, base2) will construct a point using polar
// coordinates radius=base1, angle=base2.

package {
  import flash.geom.Point;
  
  public class Model {
    // Implementation: Setter and Getter that should be assigned to functions
    public var getter:Function;
    public var setter:Function;

    // Interface: Setter and Getter called by clients
    public function get value ():* { return getter(); }
    public function set value (v:*):void { setter(v); }

    // Constructor takes the getter and setter
    public function Model(g:Function, s:Function) {
      getter = g;
      setter = s;
    }

    // Connect the model to another object
    public static function ref(obj:*, prop:*):Model {
      return new Model(
                       function():* { return obj[prop]; },
                       function(v:*):void { obj[prop] = v; }
                       );
    }

    // Connect the model to a constant
    public static function constant(value:*):Model {
      return new Model(
                       function():* { return value; },
                       function(ignore:*):void { /* no updates */ }
                       );
    }

    // Adapter: Number added to constant
    public function add(n:Number):Model {
      var that:Model = this;
      return new Model(
                       function():Number { return that.value + n; },
                       function(v:Number):void { that.value = v - n; }
                       );
    }
    
    // Adapter: Number multiplied by constant
    public function multiply(n:Number):Model {
      var that:Model = this;
      return new Model(
                       function():Number { return that.value * n; },
                       function(v:Number):void { that.value = v / n; }
                       );
    }
    
    // Adapter: Point to offset Point
    public function offset(p:Point):Model {
      var that:Model = this;
      return new Model(
                       function():Point { return that.value.add(p); },
                       function(v:Point):void { that.value = v.subtract(p); }
                       );
    }
    
    // Adapter: distance Number to Point along vector
    public function project(dir:Point):Model {
      var that:Model = this;
      return new Model(
                       function():Point {
                         var v:Number = that.value;
                         return new Point(v * dir.x, v * dir.y);
                       },
                       function(v:Point):void {
                         that.value = (v.x * dir.x + v.y * dir.y) /
                           (dir.x * dir.x + dir.y * dir.y);
                       });
    }

    // Adapter: clamped Number to unclamped Number
    public function clamped(min:Number, max:Number):Model {
      var that:Model = this;
      return new Model(
                       function():Number { return that.value; },
                       function(v:Number):void {
                         that.value = Math.max(min, Math.min(max, v));
                       }
                       );
    }

    // Adapter: rounded Number to unrounded Number
    public function rounded(nearest:Number = 1.0):Model {
      var that:Model = this;
      return new Model(
                       function():Number { return that.value; },
                       function(v:Number):void {
                         that.value = nearest * Math.round(v/nearest);
                       }
                       );
    }

    // Binary adapter: Cartesian coordinates
    public static function Cartesian(x:Model, y:Model):Model {
      return new Model(
                       function():Point {
                         return Point.polar(x.value, y.value);
                       },
                       function(value:Point):void {
                         x.value = value.x;
                         y.value = value.y;
                       }
                       );
    }
      
    // Binary adapter: Polar coordinates
    public static function Polar(radius:Model, angle:Model):Model {
      return new Model(
                       function():Point {
                         return Point.polar(radius.value, angle.value);
                       },
                       function(value:Point):void {
                         radius.value = value.length;
                         angle.value = Math.atan2(value.y, value.x);
                       }
                       );
    }
  }
}
