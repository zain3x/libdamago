package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.Bounds;

import flash.geom.Point;

public class SnapAnchorBounded extends SnapAnchor
{
    public function SnapAnchorBounded (type :SnapType, bounds :Bounds, maxSnapDistance :Number = 20)
    {
        super(type, maxSnapDistance);
        _bounds = bounds;
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
        return _bounds.distance(globalCenter);
//        return SnapUtil.getSnappableDistanceFromSnapRect(this, d, _snapAxis, _maxSnapDistance);
    }

    /**
     * The point to snap to is the center of the boundsDisplay.
     */
    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        //TODO handle more than points
        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
        var boundedPoint :Point = _bounds.getBoundedPoint(globalCenter.x, globalCenter.y);
        return boundedPoint;
//        var localPoint :Point = DisplayUtil.transformPoint(new Point(0,0), d.boundsDisplayObject,
//            displayContainer);
//        var boundedPoint :Point = _bounds.getBoundedPoint(localPoint.x, localPoint.y);
//        return displayContainer.localToGlobal(boundedPoint);
//
    }

    protected var _bounds :Bounds;
    protected var _snapAxis :SnapAxis = SnapAxis.X_AND_Y;

}
}