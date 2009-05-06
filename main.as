package {
  import flash.geom.*;
  import flash.display.*;
  import flash.events.*;
  
  public class main extends Sprite {
    public static var scale:Number = 10.0;
    
    public var paths:Array = [];
    public var vehicles:Array = [];

    public function main() {
      addChild(new Debug(this));

      var vertices:Array = [[2, 10], [3, 8], [4, 7],
                            [16, 5], [35, 12], [40, 15],
                            [41, 16], [42, 18], [41, 20],
                            [38, 21], [25, 22], [10, 22], [5, 20], [2, 15]];

      for (var i:int = 0; i < vertices.length; i++) {
        var path:Path = new Path(i+1);
        path.endPosition = new Point(vertices[i][0], vertices[i][1]);
        paths.push(path);
      }
      for (i = 0; i < vertices.length; i++) {
        var j:int = (i+1) % vertices.length;
        paths[i].next = paths[j].id;
        paths[i].beginPosition = paths[j].endPosition;
        paths[i].length = paths[i].endPosition.subtract(paths[i].beginPosition).length;
      }

      vehicles = vehicles.concat(createTrain(1+vehicles.length, 1, 2));
      vehicles = vehicles.concat(createTrain(1+vehicles.length, 6, 5));
      vehicles = vehicles.concat(createTrain(1+vehicles.length, 11, 3));
      
      addEventListener(Event.ENTER_FRAME, onEnterFrame);
    }

    public function createTrain(startingId:int, pathId:int, cars:int):Array {
      var results:Array = [];

      var position:Number = 0.0;
      var spacing:Number = 0.3;
      for (var i:int = 0; i < cars; i++) {
        var vehicle:Vehicle = new Vehicle(startingId);
        startingId++;

        vehicle.begin = new PathPosition(pathId, position);
        position += (i == 0)? 0.5 : 2.0;
        vehicle.end = new PathPosition(pathId, position);
        position += spacing;

        results.push(vehicle);
      }

      return results;
    }
      
    public function onEnterFrame(e:Event):void {
      graphics.beginFill(0x990000);
      graphics.drawRect(0, 0, 10, 10);
      graphics.endFill();

      for each (var v:Vehicle in vehicles) {
          moveVehicle(v, 0.1);
        }
      draw();
    }
    
    public function draw():void {
      graphics.clear();

      graphics.beginFill(0x999900);
      graphics.drawRect(0, 0, 10, 10);
      graphics.endFill();
      
      // Draw all paths
      for each (var path:Path in paths) {
          graphics.lineStyle(scale, 0x000000, 0.5);
          graphics.moveTo(scale * path.beginPosition.x,
                          scale * path.beginPosition.y);
          graphics.lineTo(scale * path.endPosition.x,
                          scale * path.endPosition.y);
          graphics.lineStyle();
        }

      // Draw all vehicles
      for each (var v:Vehicle in vehicles) {
          var p:Point;
          graphics.lineStyle(scale*0.7, 0x77ffbb, 1.0, false, LineScaleMode.NORMAL, CapsStyle.NONE);
          p = pathToPosition(v.begin);
          graphics.moveTo(scale * p.x, scale * p.y);
          p = pathToPosition(v.end);
          graphics.lineTo(scale * p.x, scale * p.y);
          graphics.lineStyle();
        }

      graphics.beginFill(0x00ff00);
      graphics.drawRect(0, 0, 10, 10);
      graphics.endFill();
    }

    public function pathToPosition(pos:PathPosition):Point {
      var path:Path = lookupPath(pos.path);
      var p:Point = Point.interpolate(path.endPosition,
                                      path.beginPosition,
                                      pos.position / path.length);
      return p;
    }

    public function lookupPath(id:int):Path {
      for each (var path:Path in paths) {
          if (path.id == id) {
            return path;
          }
        }
      Debug.trace("lookupPath(", id, "): path not found");
      return null;
    }

    public function moveVehicle(v:Vehicle, d:Number):void {
      function movePathPosition(p:PathPosition):void {
        p.position -= d;
        while (p.position < 0.0) {
          var oldPath:Path = lookupPath(p.path);
          var newPath:Path = lookupPath(oldPath.next);
          p.path = newPath.id;
          p.position += newPath.length;
        }
      }

      movePathPosition(v.begin);
      movePathPosition(v.end);
    }
  }
}
