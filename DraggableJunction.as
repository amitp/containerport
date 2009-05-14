package {
  import flash.display.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.events.*;
  
  public class DraggableJunction extends Sprite {
    private var callback:Function = null;
    private var baseX:Number = 0.0;
    private var baseY:Number = 0.0;
    
    function DraggableJunction(callback:Function) {
      this.callback = callback;
      
      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

      alpha = 0.5;
      graphics.beginFill(0x333366);
      graphics.drawCircle(0, 0, 5);
      graphics.endFill();
    }

    public var dragging:Boolean = false;

    public function onMouseDown(e:MouseEvent):void {
      dragging = true;
      filters = [new GlowFilter(0xccffcc), new DropShadowFilter()];
      alpha = 1.0;
      baseX = x - e.stageX;
      baseY = y - e.stageY;
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    public function onMouseUp(e:MouseEvent):void {
      // TODO: see
      // http://www.kirupa.com/forum/showthread.php?s=bfbfb51b877a061d4907d6b16833a426&p=1948182#post1948182
      // for detecting mouse-up outside the sprite
      dragging = false;
      filters = [];
      alpha = 0.5;
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    public function onMouseDrag(e:MouseEvent):void {
      var newX:Number = e.stageX;
      var newY:Number = e.stageY;
      // Note: we have to copy these values because they are computed
      // based on x,y, and we are changing x,y.
      x = baseX + newX;
      y = baseY + newY;
      callback();
    }
    
    public function onMouseOut(e:MouseEvent):void {
      // TODO: is this different from Event.MOUSE_LEAVE on the stage?
      if (!dragging) {
        alpha = 0.5;
        filters = [];
      }
    }
    
    public function onMouseOver(e:MouseEvent):void {
      if (!dragging) {
        alpha = 1.0;
        filters = [new DropShadowFilter()];
      }
    }
  }
}
