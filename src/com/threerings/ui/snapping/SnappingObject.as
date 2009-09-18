//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;

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
    public function SnappingObject (boundsObject :DisplayObject, rootLayer :DisplayObject = null)
    {
        _boundsDisplay = boundsObject;
        _rootLayer = rootLayer == null ? _boundsDisplay : rootLayer;
    }

    public function get boundsDisplayObject () :DisplayObject
    {
        return _boundsDisplay;
    }

    public function get displayObject () :DisplayObject
    {
        return _rootLayer;
    }

    internal function shutdown () :void
    {
        _boundsDisplay = null;
        _rootLayer = null;
    }

//    public function snapCenterOfBoundsToPoint (target :Point) :void
//    {
//        var parent :DisplayObject = _rootLayer.parent;
//        var boundsBounds :Rectangle = _boundsDisplay.getBounds(parent);
//        var rootBounds :Rectangle = _rootLayer.getBounds(parent);
//
//        var boundsCenterX :Number = boundsBounds.left + boundsBounds.width / 2;
//        var boundsCenterY :Number = boundsBounds.top + boundsBounds.height / 2;
//
//        _rootLayer.x = _rootLayer.x + (target.x - boundsCenterX);
//        _rootLayer.y = _rootLayer.y + (target.y - boundsCenterY);
//    }


    /**
     *
     * @default
     */
    protected var _boundsDisplay :DisplayObject;
    /**
     *
     * @default
     */
    protected var _rootLayer :DisplayObject;

}
}