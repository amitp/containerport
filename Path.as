package {
  import flash.geom.*;
  
  public class Path {
    public var id:int;
    public var next:int;

    // Positions are in world coordinates, not Flash coordinates
    public var beginPosition:Point;
    public var beginOrientation:Point;
    public var endPosition:Point;
    public var endOrientation:Point;

    public var length:Number;

    public function Path(id_:int) {
      id = id_;
    }
  }
}

    