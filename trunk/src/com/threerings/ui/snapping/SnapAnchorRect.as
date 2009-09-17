//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;

public class SnapAnchorRect extends SnapAnchor
{
    public function SnapAnchorRect (snappingObj :DisplayObjectContainer, snapAxis :SnapDirection,
        maxSnapDistance :Number = 20)
    {
        super(snappingObj, maxSnapDistance);
        _snapAxis = snapAxis;
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        return SnapUtil.getSnappableDistanceFromSnapRect(this, d, _snapAxis, _maxSnapDistance);
    }

    /**
     * The point to snap to is the center of the boundsDisplay.
     */
    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        return SnapUtil.getGlobalSnapToPointFromRectOuter(this, d, _snapAxis, _maxSnapDistance);
    }

    protected var _snapAxis :SnapDirection;
}
}