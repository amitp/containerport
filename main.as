package {
  import flash.geom.*;
  import flash.display.*;
  import flash.events.*;
  import flash.filters.*;
  
  public class main extends Sprite {
    public static var scale:Number = 10.0;

    public var junctions:Array = [];
    public var paths:Array = [];
    public var vehicles:Array = [];
    public var pathsFromJunction:Object = {};

    public var roadLayer:Sprite = new Sprite();
    public var vehicleLayer:Sprite = new Sprite();
    
    public function main() {
      addChild(new Debug(this));
      addChild(roadLayer);
      addChild(vehicleLayer);
      vehicleLayer.filters = [new DropShadowFilter()];
      
      var vertices:Array = [[2, 10], [3, 8], [4, 7],
                            [16, 5], [35, 12], [40, 15],
                            [41, 16], [42, 18], [41, 20],
                            [38, 21], [25, 22], [10, 22], [5, 20], [2, 15]];

      var draggableJunctions:Array = [];

      function updateRoads():void {
        for (var i:int = 0; i < vertices.length; i++) {
          junctions[i].p.x = draggableJunctions[i].x / scale;
          junctions[i].p.y = draggableJunctions[i].y / scale;
        }
      }
      
      for (var i:int = 0; i < vertices.length; i++) {
        junctions[i] = new Junction(i, vertices[i][0], vertices[i][1]);
        pathsFromJunction[i] = [];
        
        var drag:DraggableJunction = new DraggableJunction(function ():void {
            updateRoads();
            drawRoads();
          });
        drag.x = junctions[i].p.x * scale;
        drag.y = junctions[i].p.y * scale;
        draggableJunctions.push(drag);
        addChild(drag);
      }
      
      for (i = 0; i < vertices.length; i++) {
        var path:Path = new Path(i);
        path.begin = junctions[(i+1) % vertices.length];
        path.end = junctions[i];
        paths.push(path);
        pathsFromJunction[path.end.id].push(path);
      }

      vehicles = vehicles.concat(createTrain(1+vehicles.length, 1, 2));
      vehicles = vehicles.concat(createTrain(1+vehicles.length, 8, 10));
      vehicles = vehicles.concat(createTrain(1+vehicles.length, 11, 3));
      
      addEventListener(Event.ENTER_FRAME, onEnterFrame);

      drawRoads();
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
      for each (var v:Vehicle in vehicles) {
          moveVehicle(v, 0.1);
        }
      drawVehicles();
    }

    public function drawRoads():void {
      roadLayer.graphics.clear();
      
      // Draw all paths
      for each (var style:Array in [[1.8, 0xcccccc, 1.0], [1.0, 0x000000, 1.0], [0.9, 0x999999, 0.8], [0.0, 0xffffff, 0.1]]) {
          roadLayer.graphics.lineStyle(scale * style[0], style[1], style[2]);
          for each (var path:Path in paths) {
              roadLayer.graphics.moveTo(scale * path.begin.p.x,
                              scale * path.begin.p.y);
              roadLayer.graphics.lineTo(scale * path.end.p.x,
                              scale * path.end.p.y);
            }
          roadLayer.graphics.lineStyle();
        }
      roadLayer.cacheAsBitmap = true;
    }
    
    public function drawVehicles():void {
      vehicleLayer.graphics.clear();
      // Draw all vehicles
      for each (var v:Vehicle in vehicles) {
          var p:Point;
          vehicleLayer.graphics.lineStyle(scale*0.7, 0x77ffbb, 1.0, false, LineScaleMode.NORMAL, CapsStyle.NONE);
          p = pathToPosition(v.begin);
          vehicleLayer.graphics.moveTo(scale * p.x, scale * p.y);
          p = pathToPosition(v.end);
          vehicleLayer.graphics.lineTo(scale * p.x, scale * p.y);
          vehicleLayer.graphics.lineStyle();
        }
    }

    public function pathToPosition(pos:PathPosition):Point {
      var path:Path = lookupPath(pos.path);
      var p:Point = Point.interpolate(path.end.p, path.begin.p,
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
          var newPath:Path = pathsFromJunction[oldPath.begin.id][0];
          p.path = newPath.id;
          p.position += newPath.length;
        }
      }

      movePathPosition(v.begin);
      movePathPosition(v.end);
    }
  }
}
