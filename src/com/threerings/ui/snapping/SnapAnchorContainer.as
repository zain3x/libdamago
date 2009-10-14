package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
import com.threerings.ui.bounds.BoundsPolygon;

import flash.geom.Rectangle;


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
        var snappableGlobalBounds :Rectangle = snappable.globalBounds.boundingRect();
        //For now assume that the containter is a rect
        var containerBounds :Rectangle = _boundsGlobal.boundingRect();

        if (snappableGlobalBounds.top < containerBounds.top) {
            snappable.displayObject.y += containerBounds.top - snappableGlobalBounds.top;
        }
        if (snappableGlobalBounds.bottom > containerBounds.bottom) {
            snappable.displayObject.y -= snappableGlobalBounds.bottom - containerBounds.bottom;
        }
        if (snappableGlobalBounds.left < containerBounds.left) {
            snappable.displayObject.x += containerBounds.left - snappableGlobalBounds.left;
        }
        if (snappableGlobalBounds.right > containerBounds.right) {
            snappable.displayObject.x -= snappableGlobalBounds.right - containerBounds.right;
        }





//        if (BoundsPolygon(_boundsGlobal).containsBounds(snappable.globalBounds)) {
//            return;
//        }
//
//
//        super.snapObject(snappable);
    }

}
}
