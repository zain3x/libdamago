package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
import com.threerings.ui.bounds.BoundsPolygon;


/**
 * "Snaps" even when the object is contained, and not moved.
 * @author dion
 */
public class SnapAnchorContainer extends SnapAnchorBounded
{
    public function SnapAnchorContainer (globalBounds :Bounds, idx :int = 0,
        maxSnapDistance :Number = 20)
    {
        super(globalBounds, idx, maxSnapDistance);
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        if (BoundsPolygon(_boundsGlobal).containsBounds(d.globalBounds)) {
            return _maxSnapDistance;
        }
        return super.getSnappableDistance(d);
    }

    override public function snapObject (snappable :ISnappingObject) :void
    {
        if (BoundsPolygon(_boundsGlobal).containsBounds(snappable.globalBounds)) {
            return;
        }
        super.snapObject(snappable);
    }

}
}