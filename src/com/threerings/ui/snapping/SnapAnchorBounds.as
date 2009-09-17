package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.Bounds;

import flash.display.DisplayObjectContainer;

public class SnapAnchorBounds extends SnapAnchor
{
    public function SnapAnchorBounds(displayObject:DisplayObjectContainer, bounds :Bounds,
        maxSnapDistance :Number = 20)
    {
        super(displayObject, maxSnapDistance);
        _bounds = bounds;
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
        var localPoint :Point = DisplayUtil.transformPoint(new Point(0,0), d.boundsDisplayObject,
            displayContainer);
        var boundedPoint :Point = _bounds.getBoundedPoint(localPoint.x, localPoint.y);
        return displayContainer.localToGlobal(boundedPoint);
    }

    protected var _bounds :Bounds;
    protected var _snapAxis :SnapAxis = SnapAxis.X_AND_Y;

}
}