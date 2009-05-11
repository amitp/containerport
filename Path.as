package {
  import flash.geom.*;
  
  public class Path {
    public var id:int;

    public var begin:Junction;
    public var end:Junction;

    public function get length():Number {
      return end.p.subtract(begin.p).length;
    }
    
    public function Path(id_:int) {
      id = id_;
    }
  }
}

    