package {
  import amitp.Debug;
  import flash.display.*;
  import flash.geom.*;

  [SWF(width="300",height="300")]
  public class demo_intersection extends Sprite {
    public var intersection:Intersection = new Intersection();

    public function demo_intersection() {
      intersection.x = 150;
      intersection.y = 150;
      addChild(intersection);
      
      for (var i:int = 0; i < intersection.approaches.length; i++) {
        var drLeft:Draggable = new Draggable
          (Model.ref(intersection.approaches[i], 'inLanes')
           .callback(intersection.redraw)
           .rounded()
           .clamped(0, 4)
           .multiply(10)
           .project(V.left(intersection.dir[i]))
           .offset(new Point(intersection.dir[i].x * 50,
                             intersection.dir[i].y * 50)));
        var drRight:Draggable = new Draggable
          (Model.ref(intersection.approaches[i], 'outLanes')
           .callback(intersection.redraw)
           .rounded()
           .clamped(0, 4)
           .multiply(10)
           .project(V.right(intersection.dir[i]))
           .offset(new Point(intersection.dir[i].x * 70,
                             intersection.dir[i].y * 70)));

        for each (var config:* in
                  [ {s: drLeft.normalShape, c: 0x0000dd},
                    {s: drLeft.hoverShape, c: 0x0000dd},
                    {s: drLeft.draggingShape, c: 0x0000ff},
                    {s: drRight.normalShape, c: 0x00dd00},
                    {s: drRight.hoverShape, c: 0x00dd00},
                    {s: drRight.draggingShape, c: 0x00ff00},
                    ]) {
            var color:int = config.c;
            with (config.s.graphics) {
              clear();
              beginFill(color);
              drawRect(-3, -3, 7, 7);
              endFill();
            }
          }
        intersection.addChild(drLeft);
        intersection.addChild(drRight);
      }
    }
  }
}
