package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.Bounds;

import flash.geom.Point;

public class SnapAnchorBounded extends SnapAnchor
{
    public function SnapAnchorBounded (type :SnapType, globalBounds :Bounds, idx :int = 0,
        maxSnapDistance :Number = 20)
    {
        super(type, idx, maxSnapDistance);
        _boundsGlobal = globalBounds;
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
        return _boundsGlobal.distance(globalCenter);
    }

    /**
     * The point to snap to is the center of the boundsDisplay.
     */
    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        //TODO handle more than points
        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
        var boundedPoint :Point = _boundsGlobal.getBoundedPoint(globalCenter.x, globalCenter.y);
        return boundedPoint;
    }

    internal var _boundsGlobal :Bounds;
//    protected var _snapAxis :SnapAxis = SnapAxis.X_AND_Y;

}
}