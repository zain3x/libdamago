//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.BoundsPoint;

import flash.geom.Point;

public class SnapAnchorPoint extends SnapAnchorBounded
{
    public function SnapAnchorPoint (p :Point)
    {
        super(SnapType.CENTER, new BoundsPoint(p));
    }

//    override public function getSnappableDistance (d :ISnappingObject) :Number
//    {
//        return SnapUtil.getSnappableDistanceFromSnapPointAnchor(this, d, _offset);
//    }
//
//    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
//    {
//        return globalBounds.localToGlobal(_offset);
//    }

}
}