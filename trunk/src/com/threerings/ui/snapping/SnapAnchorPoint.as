//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.BoundsPoint;

import flash.geom.Point;

public class SnapAnchorPoint extends SnapAnchorBounded
{
    public function SnapAnchorPoint (p :Point, index :int = 0)
    {
        super(SnapType.CENTER, new BoundsPoint(p.x, p.y), index);
    }


}
}