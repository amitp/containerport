// Generic draggable handle that controls some value. This class acts
// as the controller and view for some model value.

// There are four things to track while dragging:
//   1. Where you "picked up" the drag handle [this.dragging:Point]
//   2. Where your mouse pointer is now [event:MouseEvent]
//   3. What the underlying value is [constraint:DragConstraint]
//   4. Where the drag handle is [sprite's x,y]

// The algorithm: Controller: use the desired drag handle position
// (computed from 1 and 2) to update the underlying value, imposing
// any constraints (snapping, etc.).  Viewer: use the underlying value
// to compute a drag handle position.  Both of these functions are in
// the DragConstraint.

// This code properly handles scaling and translation of the parent
// sprite, and should handle other matrix transformations as well. It
// may not handle the parent sprite changing its transformations
// *during* a drag operation though. To use a drag handle to alter a
// sprite, make the handle a sibling of the sprite instead of its
// child.

// The Draggable sprite does *not* automatically update if you change
// the underlying value elsewhere (there is no Observer pattern
// implemented here, using [Bindable]). Call updateFromValue()
// explicitly.

// To change the graphics, you can either draw into the normalShape,
// hoverShape, draggingShape shape objects, or you can make a subclass
// that overrides draw().

// Enhancements that might be nice:
//   1. Figure out whether [Bindable] would work with Model.reference and other models.

package {
  import flash.display.*;
  import flash.filters.*;
  import flash.geom.*;
  import flash.events.*;
  
  public class Draggable extends Sprite {
    // Where the drag started in the parent's coordinates, or null if
    // not dragging. We need this to track the difference between
    // where you clicked on the handle and the center of the
    // handle. For example, if you pick up the handle from the edge,
    // the value of 'dragging' will be that edge position, in global
    // coordinates.
    public var dragging:Point = null;
    public var hovering:Boolean = false;
    
    // The mapping to and from the underlying value ("model"). This
    // can be changed at any time; call updateFromValue() to update
    // the drag handle position.
    public var model:Model;

    public var normalShape:Shape = new Shape();
    public var hoverShape:Shape = new Shape();
    public var draggingShape:Shape = new Shape();
    
    public function Draggable(model:Model) {
      this.model = model;
      updateFromValue();

      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

      hoverShape.visible = false;
      draggingShape.visible = false;

      addChild(normalShape);
      addChild(hoverShape);
      addChild(draggingShape);
      
      draw();
    }

    // Draw the drag handle onto the three shape objects
    public function draw():void {
      normalShape.alpha = 0.5;
      normalShape.graphics.beginFill(0xddeeee);
      normalShape.graphics.drawCircle(0, 0, 7);
      normalShape.graphics.endFill();
      normalShape.filters = [new BevelFilter(2)];

      hoverShape.graphics.beginFill(0xffffcc);
      hoverShape.graphics.drawCircle(0, 0, 8);
      hoverShape.graphics.endFill();
      hoverShape.filters = [new BevelFilter(2), new GlowFilter(0xff0000, 0.0, 2, 2, 1)];

      draggingShape.graphics.beginFill(0x77ff77);
      draggingShape.graphics.drawCircle(0, 0, 7);
      draggingShape.graphics.endFill();
      draggingShape.filters = [new BevelFilter(2), new DropShadowFilter()];
    }

    // Set the visibility of the layers
    public function setVisibility():void {
      normalShape.visible = !dragging && !hovering;
      hoverShape.visible = hovering && !dragging;
      draggingShape.visible = !!dragging;
    }
    
    // Begin a drag operation
    public function onMouseDown(e:MouseEvent):void {
      // Calculate the relative position between the center of the
      // drag handle and the mouse down point, in global
      // coordinates. We will preserve that during the drag operation.
      var p:Point = parent.localToGlobal(new Point(x, y));
      dragging = localToGlobal(new Point(e.localX, e.localY)).subtract(p);
      setVisibility();
      
      // While dragging we "capture" the mouse by tracking it on the stage
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    // End a drag operation (only active while dragging)
    public function onMouseUp(e:MouseEvent):void {
      dragging = null;
      setVisibility();
      
      stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
      stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    // Track mouse movement (only active while dragging)
    public function onMouseDrag(e:MouseEvent):void {
      // The mouse move handler is on the stage, so we need to convert
      // from stage coordinates to the parent sprite's coordinates,
      // adjusting for the drag point while in global coordinates.
      var p:Point = new Point(e.stageX, e.stageY);
      p = stage.localToGlobal(p).subtract(dragging);
      p = parent.globalToLocal(p);

      // Update the underlying value, then update the position based on that
      model.value = p;
      updateFromValue();
    }

    // Set the Draggable Sprite's position based on the underlying value
    public function updateFromValue():void {
      var p:Point = model.value;
      x = p.x;
      y = p.y;
    }

    // TODO: Generalize mouse hover effect
    public function onMouseOver(e:MouseEvent):void {
      hovering = true;
      setVisibility();
    }
    
    public function onMouseOut(e:MouseEvent):void {
      hovering = false;
      setVisibility();
    }
    
  }
}
