package {
  import flash.geom.*;
  import flash.display.*;
  
  public class roaddemo extends Sprite {
    public var c0:Point = new Point(40, 120);
    public var c1:Point = new Point(90, 110);
    public var c2:Point = new Point(120, 118);
    public var c3:Point = new Point(150, 130);
    public var c4:Point = new Point(170, 140);

    public var roadLayer:Shape = new Shape();
    
    public function roaddemo() {
      addChild(new Debug(this));
      addChild(roadLayer);

      var c:Point = new Point(100, 100);
      c0 = c.add(Point.polar(50, Math.PI));
      c2 = c.add(Point.polar(50, Math.PI*3/4));
      c4 = c.add(Point.polar(50, Math.PI/2));
      roadLayer.y = 200;
      for each (var p:Point in [c0, c1, c2, c3, c4]) {
          addChild(new Draggable(
                                 Model.Cartesian(Model.ref(p, 'x'),
                                                 Model.ref(p, 'y'))
                                 .callback(drawTestLanes)));
        }
      drawTestLanes();
    }

    public function drawTestLanes():void {
      graphics.clear();
      roadLayer.graphics.clear();
      drawTestRoadSegment(roadLayer.graphics, c0, c1, c2, 2, 2, 3, 2);
      drawTestRoadSegment(roadLayer.graphics, c2, c3, c4, 3, 2, 3, 2);

      graphics.lineStyle(1, 0xbb6600);
      graphics.drawCircle(100, 100, 50);
      graphics.lineStyle(1, 0x669900);
      graphics.moveTo(c0.x, c0.y);
      graphics.lineTo(c1.x, c1.y);
      graphics.lineTo(c2.x, c2.y);
      graphics.lineTo(c3.x, c3.y);
      graphics.lineTo(c4.x, c4.y);
      graphics.lineStyle(1, 0x0066bb, 0.5);
      graphics.moveTo(c0.x, c0.y);
      graphics.curveTo(c1.x, c1.y, c2.x, c2.y);
      graphics.curveTo(c3.x, c3.y, c4.x, c4.y);
      var c0b:Point = Point.interpolate(c0, c1, 0.5);
      var c1b:Point = Point.interpolate(c1, c2, 0.5);
      var c1alt:Point = Point.interpolate(c0b, c1b, 0.5);
      graphics.lineStyle(0, 0xffffff, 0.5);
      graphics.moveTo(c0.x, c0.y);
      graphics.lineTo(c0b.x, c0b.y);
      graphics.lineTo(c1alt.x, c1alt.y);
      graphics.lineTo(c1b.x, c1b.y);
      graphics.lineTo(c2.x, c2.y);
      graphics.lineStyle(0, 0x000000, 0.5);
      graphics.moveTo(c0.x, c0.y);
      graphics.curveTo(c0b.x, c0b.y, c1alt.x, c1alt.y);
      graphics.curveTo(c1b.x, c1b.y, c2.x, c2.y);
      graphics.lineStyle();
    }

    public function offsetBezier(b0:Point, b1:Point, b2:Point, d0:Number, d2:Number):Array {
      var N0:Point = b1.subtract(b0); N0.normalize(1); N0 = Intersection.left(N0);
      var N2:Point = b2.subtract(b1); N2.normalize(1); N2 = Intersection.left(N2);
      
      return [b0.add(Intersection.scale(N0, d0)),
              b1.add(Intersection.scale(N0.add(N2), 0.5*(d0+d2) / (1 + (N0.x*N2.x + N0.y*N2.y)))),
              b2.add(Intersection.scale(N2, d2))];
    }
    
    public function drawTestRoadSegment(g:Graphics, b0:Point, b1:Point, b2:Point, lanesIn0:int, lanesOut0:int, lanesIn2:int, lanesOut2:int):void {
      var N0:Point = b1.subtract(b0); N0.normalize(1); N0 = Intersection.left(N0);
      var N2:Point = b2.subtract(b1); N2.normalize(1); N2 = Intersection.left(N2);

      var laneWidth:Number = 5;
      
      var inLanes:Array = offsetBezier(b0, b1, b2, -lanesIn0*laneWidth, -lanesIn2*laneWidth);
      var outLanes:Array = offsetBezier(b0, b1, b2, lanesOut0*laneWidth, lanesOut2*laneWidth);
      g.beginFill(0x000000);
      g.moveTo(inLanes[0].x, inLanes[0].y);
      g.lineStyle(1, 0xffffff);
      g.curveTo(inLanes[1].x, inLanes[1].y, inLanes[2].x, inLanes[2].y);
      g.lineStyle();
      g.lineTo(outLanes[2].x, outLanes[2].y);
      g.lineStyle(1, 0xffffff);
      g.curveTo(outLanes[1].x, outLanes[1].y, outLanes[0].x, outLanes[0].y);
      g.lineStyle();
      g.lineTo(inLanes[0].x, inLanes[0].y);
      g.endFill();

      var lanesIn:int = Math.min(lanesIn0, lanesIn2);
      var lanesOut:int = Math.min(lanesOut0, lanesOut2);
      for (var lane:int = -lanesIn+1; lane <= lanesOut-1; lane++) {
        var laneCurve:Array = offsetBezier(b0, b1, b2, lane*laneWidth, lane*laneWidth);
        g.lineStyle(1, lane == 0? 0xffff00: 0xffffff);
        if (lane != 0) {
          var matrix:Matrix = new Matrix();
          matrix.scale(4, 1);
          matrix.rotate(Math.atan2(laneCurve[2].y - laneCurve[0].y,
                                   laneCurve[2].x - laneCurve[0].x));
          var stripeBitmap:BitmapData = new BitmapData(2, 1, true, 0x00000000);
          stripeBitmap.setPixel32(0, 0, 0xffffffff);
          g.lineBitmapStyle(stripeBitmap, matrix, true, false);
        }
        g.moveTo(laneCurve[0].x, laneCurve[0].y);
        g.curveTo(laneCurve[1].x, laneCurve[1].y, laneCurve[2].x, laneCurve[2].y);
      }

      g.lineStyle();
    }
  }
}
