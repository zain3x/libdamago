package com.threerings.ui.snapping
{
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.Bounds;

import flash.geom.Point;

import libdamago.geometry.LineSegment;
import libdamago.geometry.Polygon;

/**
 * This class also notifies the
 */
public class SnapAnchorBounded extends SnapAnchor
{
    public function SnapAnchorBounded (globalBounds :Bounds, idx :int = -1,
        maxSnapDistance :Number = 20)
    {
        super(idx, maxSnapDistance);
        _boundsGlobal = globalBounds;
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
//        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
        return _boundsGlobal.distance(d.globalBounds);
    }

    /**
     * The point to snap to is the center of the boundsDisplay.
     */
    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        //TODO handle more than points

        var globalCenter :Point = SnapUtil.getGlobalCenter(d.displayObject);
        //Round so as to remove weird 'wobbles'
        globalCenter.x = Math.round(globalCenter.x);
        globalCenter.y = Math.round(globalCenter.y);

        var boundedPoint :Point = _boundsGlobal.getBoundedPoint(globalCenter.x, globalCenter.y);
//        switch (_snapType) {
//            case SnapType.RECT_PERIMETER_INNER:
//
//            break;
//
//            case SnapType.RECT_PERIMETER_OUTER:
//            break;
//
//        }
        return boundedPoint;
    }

    override public function get bounds () :Bounds
    {
        return _boundsGlobal;
    }



    internal var _boundsGlobal :Bounds;
//    protected var _snapAxis :SnapAxis = SnapAxis.X_AND_Y;

}
}
