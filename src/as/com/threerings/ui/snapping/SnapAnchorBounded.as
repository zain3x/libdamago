package com.threerings.ui.snapping
{
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.Bounds;

import flash.geom.Point;

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

    override public function get bounds () :Bounds
    {
        return _boundsGlobal;
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

		var globalBounds :Bounds = d.globalBounds;
        var globalCenter :Vector2 = globalBounds.center;  
//			SnapUtil.getGlobalCenter(d.displayObject);
        //Round so as to remove weird 'wobbles'
        globalCenter.x = Math.round(globalCenter.x);
        globalCenter.y = Math.round(globalCenter.y);

        var boundedPoint :Point = _boundsGlobal.getBoundedPoint(globalCenter.x, globalCenter.y);
        return boundedPoint;
    }



    internal var _boundsGlobal :Bounds;

}
}
