package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
import com.threerings.ui.bounds.BoundsPolygon;


/**
 * "Snaps" even when the object is contained, and not moved.
 * @author dion
 */
public class SnapAnchorContainer extends SnapAnchorBounded
{
    public function SnapAnchorContainer (type:SnapType, globalBounds :Bounds, idx :int = 0,
        maxSnapDistance :Number = 20)
    {
        super(type, globalBounds, idx, maxSnapDistance);
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        if (BoundsPolygon(_boundsGlobal).containsBounds(d.globalBounds)) {
            return 0;
        }
//        var globalCenter :Point = SnapUtil.getGlobalCenter(d.boundsDisplayObject);
//        if (_boundsGlobal.contains(globalCenter.x, globalCenter.y)) {
//            return 0;
//        }
        return super.getSnappableDistance(d);
    }

}
}