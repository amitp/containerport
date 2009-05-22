// Generic draggable object.

// This code properly handles scaling and translation of the parent
// sprite, and should handle other matrix transformations as well. It
// may not handle the parent sprite changing its transformations
// *during* a drag operation though. To use a drag handle to alter a
// sprite, make the handle a sibling of the sprite instead of its
// child.

// The caller should have a value that is being tracked by the
// draggable; there must be a function to map the underlying value to
// the draggable's position, and vice versa.  Snapping and constraints
// can be expressed via these functions.  These functions are
// encapsulated into a DragConstraint object.  The DragConstraint
// class also provides some convenient factory functions for common
// constraint types.

// The Draggable sprite does *not* automatically update if you change
// the underlying value elsewhere. Call updateFromValue() explicitly.

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

    // The mapping to and from the underlying value ("model"). This
    // can be changed at any time; call updateFromValue() to update
    // the drag handle position.
    public var constraint:DragConstraint;

    public var draggingFilters:Array =
      [new GlowFilter(0xccffcc), new DropShadowFilter()];
    
    public function Draggable(constraint:DragConstraint) {
      this.constraint = constraint;
      updateFromValue();

      addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
      addEventListener(MouseEvent.MOUSE_OVER, onMouseOver);
      addEventListener(MouseEvent.MOUSE_OUT, onMouseOut);

      // TODO: better way to decide on alpha
      alpha = 0.5;

      // TODO: what about other shapes? What about changing shapes
      // during dragging or mouseover?
      graphics.beginFill(0xccff66);
      graphics.drawCircle(0, 0, 10);
      graphics.endFill();
    }

    // Begin a drag operation
    public function onMouseDown(e:MouseEvent):void {
      // Calculate the relative position between the center of the
      // drag handle and the mouse down point, in global
      // coordinates. We will preserve that during the drag operation.
      var p:Point = parent.localToGlobal(new Point(x, y));
      dragging = localToGlobal(new Point(e.localX, e.localY)).subtract(p);
      
      filters = draggingFilters;
      alpha = 1.0;

      // While dragging we "capture" the mouse by tracking it on the stage
      stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseDrag);
      stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
    }

    // End a drag operation (only active while dragging)
    public function onMouseUp(e:MouseEvent):void {
      dragging = null;
      filters = [];
      alpha = 0.5;
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
      constraint.toValue(p);
      updateFromValue();
    }

    // Set the Draggable Sprite's position based on the underlying value
    public function updateFromValue():void {
      var p:Point = constraint.fromValue();
      x = p.x;
      y = p.y;
    }

    // TODO: Generalize mouse hover effect
    public function onMouseOver(e:MouseEvent):void {
      if (!dragging) {
        alpha = 1.0;
        filters = [new DropShadowFilter()];
      }
    }
    
    public function onMouseOut(e:MouseEvent):void {
      if (!dragging) {
        alpha = 0.5;
        filters = [];
      }
    }
    
  }
}
