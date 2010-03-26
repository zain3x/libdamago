//
// $Id$

package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
import com.threerings.ui.bounds.BoundsRectangle;

import flash.display.DisplayObject;
import flash.events.IEventDispatcher;
import flash.geom.Point;

/**
 *
 * @author dion
 */
public class SnappingObject implements ISnappingObject
{

    /**
     *
     * @param boundsObject The object that will have it's bounds used for snapping
     * @param rootLayer The root display container.  If the snapping bounds are not the same
     *                  as the visual bounds, supply this parameter.
     */
    public function SnappingObject (disp :DisplayObject, bounds :Bounds = null)
    {
        if (disp == null) {
            throw new Error("Missing disp");
        }
        _disp = disp;
        _bounds = bounds;
        if (_bounds == null) { //Use the display bounds if none is supplied
            _bounds = BoundsRectangle.fromRectangle(disp.getBounds(disp));
        }
    }

    public function get globalBounds () :Bounds
    {
        return Bounds.convertToGlobal(_bounds, _disp);
    }

    public function get localBounds () :Bounds
    {
        return _bounds
    }

    public function get displayObject () :DisplayObject
    {
        return _disp;
    }

    public function get currentSnapAnchor () :ISnapAnchor
    {
        return _snapAnchor;
    }

    public function get x () :Number
    {
        return _disp.x;
    }

    public function get y () :Number
    {
        return _disp.y;
    }

    public function set currentSnapAnchor (val :ISnapAnchor) :void
    {
        _snapAnchor = val;
    }

    public function set x (val :Number) :void
    {
        _disp.x = val;
    }

    public function set y (val :Number) :void
    {
        _disp.y = val;
    }

    public function beginSnapping (snapManager :IEventDispatcher) :void
    {
    }

    public function endSnapping (anc :ISnapAnchor = null) :void
    {
    }

    public function snapCenterToGlobal (p :Point) :void
    {
        SnapUtil.snapCenterOfBoundsToGlobalPoint(this, p);
    }

    protected var _bounds :Bounds;
    protected var _disp :DisplayObject;
    protected var _snapAnchor :ISnapAnchor;
}
}
