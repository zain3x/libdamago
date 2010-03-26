//
// $Id$

package com.threerings.ui.snapping {
import flash.geom.Point;
import com.threerings.ui.bounds.BoundsPoint;

public class SnapAnchorPoint extends SnapAnchorBounded
{
    public function SnapAnchorPoint (p :Point, index :int = -1, maxSnapDistance :Number = 20)
    {
        super(new BoundsPoint(p.x, p.y), index, maxSnapDistance);
    }
}
}
