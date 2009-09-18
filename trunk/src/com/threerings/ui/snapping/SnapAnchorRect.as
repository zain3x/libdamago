//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.BoundsRectangle;

import flash.geom.Point;
import flash.geom.Rectangle;

public class SnapAnchorRect extends SnapAnchorBounded
{
    public function SnapAnchorRect (type :SnapType, rect :Rectangle)
    {
        super(type, new BoundsRectangle(rect.left, rect.top, rect.width, rect.height));
//        _snapAxis = snapAxis;
    }

//    override public function getSnappableDistance (d :ISnappingObject) :Number
//    {
//        return SnapUtil.getSnappableDistanceFromSnapRect(this, d, _snapAxis, _maxSnapDistance);
//    }
//
//    /**
//     * The point to snap to is the center of the boundsDisplay.
//     */
//    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
//    {
//        return SnapUtil.getGlobalSnapToPointFromRectOuter(this, d, _snapAxis, _maxSnapDistance);
//    }

//    protected var _snapAxis :SnapAxis;
}
}