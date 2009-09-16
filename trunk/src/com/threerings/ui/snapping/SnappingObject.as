//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.display.DisplayUtil;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

public class SnappingObject
{
    public function SnappingObject (boundsObject :DisplayObject, rootLayer :DisplayObject = null)
    {
        _boundsDisplay = boundsObject;
        _rootLayer = rootLayer == null ? _boundsDisplay : rootLayer;
    }

    internal function get boundsDisplay () :DisplayObject
    {
        return _boundsDisplay;
    }

    internal function get rootLayer () :DisplayObject
    {
        return _rootLayer;
    }

    internal function shutdown () :void
    {
        _boundsDisplay = null;
        _rootLayer = null;
    }

    internal function snapCenterOfBoundsToPoint (target :Point) :void
    {
        var parent :DisplayObject = _rootLayer.parent;
        var boundsBounds :Rectangle = _boundsDisplay.getBounds(parent);
        var rootBounds :Rectangle = _rootLayer.getBounds(parent);

        var boundsCenterX :Number = boundsBounds.left + boundsBounds.width / 2;
        var boundsCenterY :Number = boundsBounds.top + boundsBounds.height / 2;

        _rootLayer.x = _rootLayer.x + (target.x - boundsCenterX);
        _rootLayer.y = _rootLayer.y + (target.y - boundsCenterY);
    }

    protected var _boundsDisplay :DisplayObject;
    protected var _rootLayer :DisplayObject;

}
}