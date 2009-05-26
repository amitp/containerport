// A simple demo of the Draggable/Model interface

// Note: the interface doesn't easily allow for two handles
// controlling the transform of the same sprite. The parent of the
// handles can't be the sprite, so the transformation has to be
// repeated and transmitted between the two handles somehow.

package {
  import flash.geom.*;
  import flash.display.*;
  import flash.filters.*;
  
  public class dragdemo extends Sprite {
    
    public var area:Sprite = new Sprite();
    
    public function dragdemo() {
      addChild(area);

      area.filters = [new DropShadowFilter(1)];
      area.x = 200;
      area.y = 200;
      area.rotation = -90;
      area.scaleX = 0.5;
      area.scaleY = 0.5;
      area.graphics.beginFill(0xdfdf9f);
      area.graphics.drawRoundRect(-150, -150, 300, 300, 20);
      area.graphics.endFill();

      var d1:Draggable = new Draggable
        (Model.Polar(Model.ref(area, 'scaleX')
                     .callback(function():void { area.scaleY = area.scaleX; })
                     .clamped(0.2, 1.0)
                     .multiply(100),
                     Model.ref(area, 'rotation')
                     .rounded(15)
                     .multiply(Math.PI/180)
                     ).offset(new Point(200, 200))
         );
      addChild(d1);
    }
  }
}
