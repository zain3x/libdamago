//
// $Id$

package com.threerings.ui.snapping {
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.ui.bounds.BoundsRectangle;

public class SnapAnchorRect extends SnapAnchorBounded
{
    public function SnapAnchorRect (rect :Rectangle)
    {
        super(new BoundsRectangle(rect.left, rect.top, rect.width, rect.height));
    }
}
}
