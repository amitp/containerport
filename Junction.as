package {
  import flash.geom.*;
  
  public class Junction {
    public var id:int;
    public var p:Point;
    // todo: orientation

    public function Junction(id_:int, x:Number, y:Number) {
      id = id_;
      p = new Point(x, y);
    }
  }
}
