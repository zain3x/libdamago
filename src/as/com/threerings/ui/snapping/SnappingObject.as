//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;
import flash.geom.Point;
import com.threerings.ui.bounds.Bounds;
import com.threerings.ui.bounds.BoundsRectangle;
/**
 *
 * @author dion
 */
public class SnappingObject
    implements ISnappingObject
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
        if (_bounds == null) {//Use the display bounds if none is supplied
            _bounds = BoundsRectangle.fromRectangle(disp.getBounds(disp));
        }
//        _rootLayer = rootLayer == null ? _boundsDisplay : rootLayer;
    }
	
	public function get currentSnapAnchor () :ISnapAnchor
	{
		return _snapAnchor;	
	}
	
	public function set currentSnapAnchor (val :ISnapAnchor) :void
	{
		_snapAnchor = val;	
	}

//    public function get boundsDisplayObject () :DisplayObject
//    {
//        return _boundsDisplay;
//    }
//
    public function get displayObject () :DisplayObject
    {
        return _disp;
    }

//    internal function shutdown () :void
//    {
//        _boundsDisplay = null;
//        _rootLayer = null;
//    }

    public function get globalBounds () :Bounds
    {
        return Bounds.convertToGlobal(_bounds, _disp);
    }

    public function get localBounds () :Bounds
    {
        return _bounds
    }

    public function get x () :Number
    {
        return _disp.x;
    }

    public function set x (val :Number) :void
    {
        _disp.x = val;
    }
    public function get y () :Number
    {
        return _disp.y;
    }
    public function set y (val :Number) :void
    {
        _disp.y = val;
    }
	
	public function beginSnapping () :void{}
    
	public function endSnapping (anc :ISnapAnchor = null) :void {}
	
	public function snapCenterToGlobal (p :Point) :void
	{
		SnapUtil.snapCenterOfBoundsToGlobalPoint(this, p);
	}
    
    public function snapped (anchor :ISnapAnchor) :void{}

    /**
     *
     * @default
     */
    protected var _bounds :Bounds;

//    public function centerOn (globalPoint :Point) :void
//    {
//        var localPoint :Point = _disp.parent.globalToLocal(globalPoint);
//
//        DisplayUtil.positionBoundsRelative(_disp, _disp.parent,
//            localPoint.x - _disp.width / 2, localPoint.y - _disp.height / 2);
//    }

    /**
     *
     * @default
     */
    protected var _disp :DisplayObject;
	
	protected var _snapAnchor :ISnapAnchor;
//    protected var _rootLayer :DisplayObject;
}
}
