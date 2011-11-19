package {
  import flash.geom.*;
  import flash.filters.*;
  import flash.display.*;

  [SWF(width=500,height=400)]
  public class demo_roads extends Sprite {

    // Compare circle drawing to bezier approximation
    public var c:Point = new Point(180, 200);
    public var b0:Point = Point.polar(100, Math.PI);
    public var b1:Point = Point.polar(150, Math.PI*2/3);
    public var b2:Point = Point.polar(100, Math.PI/3);

    // Left side: bezier roads
    public var c0:Point = new Point(150, 30);
    public var c1:Point = new Point(50, 20);
    public var c2:Point = new Point(25, 120);
    public var c3:Point = new Point(10, 180);
    public var c4:Point = new Point(30, 240);

    // Right side: arc roads
    public var a0:Point = new Point(250, 30);
    public var a1:Point = new Point(370, 150);
    public var a2:Point = new Point(300, 300);
    public var ak:Number = 70;

    // Right side: what the same arc road would look like with bezier
    public var overlayArc:Sprite = new Sprite();
    public var overlayBez:Sprite = new Sprite();

    // Number of lanes in various areas
    public var lanesL0:int = 2;
    public var lanesR0:int = 3;
    public var lanesL1:int = 3;
    public var lanesR1:int = 3;
    public var lanesL2:int = 3;
    public var lanesR2:int = 2;
    
    public function demo_roads() {
      overlayBez.alpha = 0.2;
      addChild(overlayBez);
      addChild(overlayArc);
      
      b0 = b0.add(c);
      b1 = b1.add(c);
      b2 = b2.add(c);

      var laneModels = ['lanesL0', 'lanesR0', 'lanesL1', 'lanesR1', 'lanesL2', 'lanesR2'];
      for (var i:int = 0; i < laneModels.length; i++) {
        addChild(new Draggable(Model.Cartesian(Model.ref(this, laneModels[i])
                                               .clamped(1, 5)
                                               .rounded()
                                               .multiply(10)
                                               .add(10 + 60 * Math.floor(i/2)),
                                               Model.constant(360 + 30 * (i%2)))
                               .callback(redraw)));
      }
                                             
      addChild(new Draggable(Model.Cartesian(Model.constant(390),
                                             Model.ref(this, 'ak')
                                             .clamped(10, 150)
                                             .add(20))
                             .callback(redraw)));
      
      for each (var p:Point in [c0, c1, c2, c3, c4, b0, b1, b2, a0, a1, a2]) {
          var draggable:Draggable =
                   new Draggable(
                                 Model.Cartesian(Model.ref(p, 'x'),
                                                 Model.ref(p, 'y'))
                                 .callback(redraw));
          draggable.normalShape.alpha = 0.9;
          draggable.normalShape.filters = [new BevelFilter(1)];
          for each (var config:* in
                    [{shape: draggable.normalShape, color: 0xcccccc, size:4},
                     {shape: draggable.hoverShape, color: 0x99ff00, size:5},
                     {shape: draggable.draggingShape, color: 0x99ff00, size:5}
                     ]) {
              var g:Graphics = config.shape.graphics;
              g.clear();
              g.beginFill(0x000000, 0.01); /* increase active area */
              g.drawCircle(0, 0, config.size+5);
              g.endFill();
              g.lineStyle(1, 0x000000);
              g.beginFill(config.color);
              g.drawCircle(0, 0, config.size);
              g.endFill();
              g.lineStyle();
            }
          addChild(draggable);
        }
      redraw();
    }

    public function redraw():void {
      graphics.clear();

      // Draw a background
      graphics.beginFill(0xbbbb99);
      graphics.drawRect(0, 0, 500, 400);
      graphics.endFill();
      
      // Draw a slider base for the arc size slider
      graphics.lineStyle(5, 0x777777);
      graphics.moveTo(390, 30);
      graphics.lineTo(390, 170);
      graphics.lineStyle();

      // Draw the Bezier curve road
      drawTestRoadSegment(graphics, c0, c1, c2, lanesR1, lanesL1, lanesR1, lanesL1);
      drawTestRoadSegment(graphics, c2, c3, c4, lanesR1, lanesL1, lanesR2, lanesL2);

      // Draw a circle and a Bezier curve approximating it
      graphics.lineStyle(1, 0xbb6600);
      graphics.drawCircle(c.x, c.y, 100);
      graphics.lineStyle(1, 0x669900);
      graphics.moveTo(b0.x, b0.y);
      graphics.lineTo(b1.x, b1.y);
      graphics.lineTo(b2.x, b2.y);
      graphics.lineStyle(1, 0x0066bb, 0.5);
      graphics.moveTo(b0.x, b0.y);
      graphics.curveTo(b1.x, b1.y, b2.x, b2.y);
      var b0b:Point = Point.interpolate(b0, b1, 0.5);
      var b1b:Point = Point.interpolate(b1, b2, 0.5);
      var b1alt:Point = Point.interpolate(b0b, b1b, 0.5);
      graphics.lineStyle(0, 0xffffff, 0.5);
      graphics.moveTo(b0.x, b0.y);
      graphics.lineTo(b0b.x, b0b.y);
      graphics.lineTo(b1alt.x, b1alt.y);
      graphics.lineTo(b1b.x, b1b.y);
      graphics.lineTo(b2.x, b2.y);
      graphics.lineStyle(0, 0x000000, 0.5);
      graphics.moveTo(b0.x, b0.y);
      graphics.curveTo(b0b.x, b0b.y, b1alt.x, b1alt.y);
      graphics.curveTo(b1b.x, b1b.y, b2.x, b2.y);
      graphics.lineStyle();

      // Draw a road that uses a circular arc to join straight segments
      var graphics1:Graphics = overlayArc.graphics;
      graphics1.clear();
      var a10:Point = a0.subtract(a1); a10.normalize(1);
      var a12:Point = a2.subtract(a1); a12.normalize(1);
      var p:Point = V.intersection
        (a1.add(V.scale(a10, ak)), V.left(a10),
         a1.add(V.scale(a12, ak)), V.right(a12));

      var p1:Point = V.intersection(a1, a10, p, V.left(a10));
      var p2:Point = V.intersection(a1, a12, p, V.right(a12));

      drawTestRoadSegment(graphics1, a0, Point.interpolate(a0, p1, 0.5), p1, lanesL0, lanesR0, lanesL1, lanesR1);
      drawTestRoadSegment(graphics1, p2, Point.interpolate(p2, a2, 0.5), a2, lanesL1, lanesR1, lanesL2, lanesR2);
      drawPoint(graphics1, p, 0xffff00, 3, 0x000000);
      drawPoint(graphics1, p1, 0xffff00, 2, 0x000000);
      drawPoint(graphics1, p2, 0xffff00, 2, 0x000000);
      graphics1.lineStyle(1, 0xffff00, 0.5);
      graphics1.moveTo(p1.x, p1.y);
      graphics1.lineTo(p.x, p.y);
      graphics1.lineTo(p2.x, p2.y);
      graphics1.lineStyle();

      // Split arc into segments, each approximated by a bezier curve
      var threshold:Number = Math.PI/2;
      function drawArc(center:Point, radius:Number, angle1:Number, angle2:Number):void {
        var angle:Number = 0.5 * (angle1 + angle2);
        var da:Number = angle2 - angle1;
        if (da < 0.0) da += 2 * Math.PI;

        if (da > Math.PI / 4) {
          drawArc(center, radius, angle1, angle);
          drawArc(center, radius, angle, angle2);
        } else {
          var p1:Point = center.add(Point.polar(radius, angle1));
          var p2:Point = center.add(Point.polar(radius, angle2));
          var pc:Point = center.add(Point.polar(radius / Math.cos(da/2), angle));
          
          drawTestRoadSegment(graphics1, p1, pc, p2, lanesL1, lanesR1, lanesL1, lanesR1);
        }
      }

      drawArc(p, p.subtract(p1).length,
              Math.atan2(p1.y-p.y, p1.x-p.x),
              Math.atan2(p2.y-p.y, p2.x-p.x));

      // Show what the same road looks like with bezier curves
      var graphics2:Graphics = overlayBez.graphics;
      graphics2.clear();
      drawTestRoadSegment(graphics2, a0, Point.interpolate(a0, p1, 0.5), p1, lanesL0, lanesR0, lanesL1, lanesR1);
      drawTestRoadSegment(graphics2, p1, a1, p2, lanesL1, lanesR1, lanesL1, lanesR1);
      drawTestRoadSegment(graphics2, p2, Point.interpolate(p2, a2, 0.5), a2, lanesL1, lanesR1, lanesL2, lanesR2);
    }

    public function offsetBezier(b0:Point, b1:Point, b2:Point, d0:Number, d2:Number):Array {
      var N0:Point = b1.subtract(b0); N0.normalize(1); N0 = V.left(N0);
      var N2:Point = b2.subtract(b1); N2.normalize(1); N2 = V.left(N2);
      
      return [b0.add(V.scale(N0, d0)),
              b1.add(V.scale(N0.add(N2), 0.5*(d0+d2) / (1 + (N0.x*N2.x + N0.y*N2.y)))),
              b2.add(V.scale(N2, d2))];
    }

    public function drawPoint(g:Graphics, p:Point,
                              color:int, radius:int, outline:int):void {
      graphics.lineStyle(1, outline, 0.5);
      graphics.beginFill(color);
      graphics.drawCircle(p.x, p.y, radius);
      graphics.endFill();
      graphics.lineStyle();
    }
      
    public function drawTestRoadSegment(g:Graphics, b0:Point, b1:Point, b2:Point, lanesIn0:int, lanesOut0:int, lanesIn2:int, lanesOut2:int):void {
      var N0:Point = b1.subtract(b0); N0.normalize(1); N0 = V.left(N0);
      var N2:Point = b2.subtract(b1); N2.normalize(1); N2 = V.left(N2);

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
