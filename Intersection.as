package {
  import flash.display.*;
  import flash.geom.*;
  
  public class Intersection extends Sprite {
    // TODO: separate representation and drawing code once I finish experimenting

    public var approaches:Array = [new Approach(), new Approach(),
                                   new Approach(), new Approach()];
    public var dir:Array = [new Point(+1, 0), new Point(0, +1),
                            new Point(-1, 0), new Point(0, -1)];
    
    public function Intersection() {
      redraw();
    }

    public function redraw():void {
      graphics.clear();

      var intersectionBoundary:Array = [];
      
      for (var i:int = 0; i < approaches.length; i++) {
        var p:Point, v:Point;

        p = scale(dir[i], 40);
        v = left(dir[i]);
        graphics.beginFill(0x000000);
        drawPath([p, p.add(scale(dir[i], 100)),
                  p.add(scale(dir[i], 100)).add(scale(v, 10*approaches[i].inLanes)),
                  p.add(scale(v, 10*approaches[i].inLanes))]);
        graphics.endFill();
                        
        for (var lane:int = 0; lane < approaches[i].inLanes; lane++) {
          if (lane != 0)
            drawLane(p.add(scale(v, 10*lane)), dir[i], 0xffffff, true);
          if (lane == 0)
            drawLane(p.add(scale(v, 10*lane+1)), dir[i], 0xffff00, false);
          if (lane == approaches[i].inLanes-1)
            drawLane(p.add(scale(v, 10*lane+9)), dir[i], 0xffffff, false);
        }

        graphics.lineStyle(1, 0xffffff, 1.0, false, LineScaleMode.NORMAL, CapsStyle.NONE);
        drawPath([p, p.add(scale(v, 10*approaches[i].inLanes - 1))]);
        graphics.lineStyle();
        
        intersectionBoundary.push(p.add(scale(v, 10*approaches[i].inLanes-1)));

        p = scale(dir[i], 40);
        v = right(dir[i]);
        graphics.beginFill(0x000000);
        drawPath([p, p.add(scale(dir[i], 100)),
                  p.add(scale(dir[i], 100)).add(scale(v, 10*approaches[i].outLanes)),
                  p.add(scale(v, 10*approaches[i].outLanes))]);
        graphics.endFill();
        for (lane = 0; lane < approaches[i].outLanes; lane++) {
          if (lane != 0)
            drawLane(p.add(scale(v, 10*lane)), dir[i], 0xffffff, true);
          if (lane == 0)
            drawLane(p.add(scale(v, 10*lane+1)), dir[i], 0xffff00, false);
          if (lane == approaches[i].outLanes-1)
            drawLane(p.add(scale(v, 10*lane+9)), dir[i], 0xffffff, false);
        }

        intersectionBoundary.push(p.add(scale(v, 10*approaches[i].outLanes-1)));
      }

      graphics.beginFill(0x000000);
      graphics.moveTo(intersectionBoundary[approaches.length*2-1].x, intersectionBoundary[approaches.length*2-1].y);
      for (i = 0; i < approaches.length; i++) {
        graphics.lineStyle(1, 0xffffff);
        graphics.lineTo(intersectionBoundary[2*i].x,
                        intersectionBoundary[2*i].y);
        graphics.lineStyle();
        graphics.lineTo(intersectionBoundary[2*i+1].x,
                        intersectionBoundary[2*i+1].y);
      }
      graphics.endFill();
      graphics.lineStyle();
    }

    public function drawLane(p:Point, v:Point, color:int, striped:Boolean):void {
      graphics.lineStyle(1, color);
      if (striped) {
        var matrix:Matrix = new Matrix();
        matrix.translate(p.x, p.y);
        matrix.scale(4, 1);
        matrix.rotate(Math.atan2(v.y, v.x));
        var stripeBitmap:BitmapData = new BitmapData(2, 1, true, 0x00000000);
        stripeBitmap.setPixel32(0, 0, 0xff000000 | color);
        graphics.lineBitmapStyle(stripeBitmap, matrix, true, false);
      }
      graphics.moveTo(p.x, p.y);
      graphics.lineTo(p.x + v.x * 100, p.y + v.y * 100);
      graphics.lineStyle();
    }

    public function drawPath(p:Array):void {
      if (p.length > 0) {
        graphics.moveTo(p[0].x, p[0].y);
        for (var i:int = 1; i < p.length; i++) {
          graphics.lineTo(p[i].x, p[i].y);
        }
      }
    }
    
    public static function scale(v:Point, k:Number):Point {
      return new Point(v.x * k, v.y * k);
    }
    public static function left(v:Point):Point {
      return new Point(v.y, -v.x);
    }
    public static function right(v:Point):Point {
      return new Point(-v.y, v.x);
    }
  }
}

class Approach {
  public var inLanes:int = 1;
  public var outLanes:int = 1;
}
