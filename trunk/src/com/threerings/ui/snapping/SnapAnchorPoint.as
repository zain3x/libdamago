//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.ui.DisplayUtils;
import com.threerings.util.MathUtil;

public class SnapAnchorPoint extends SnapAnchor
{
    public function SnapAnchorPoint (d :DisplayObject, parent :Sprite)
    {
        super(SnapType.POINT, d);
        _point = DisplayUtils.getBoundsCenterRelativeTo(d, parent);
        _parent = parent;
    }

    override internal function getSnappableDistance (d :SnappingObject) :Number
    {
        var bounds :Rectangle = d.boundsDisplay.getBounds(_parent);
        var centerX :Number = bounds.left + bounds.width / 2;
        var centerY :Number = bounds.top + bounds.height / 2;
        return MathUtil.distance(_point.x, _point.y, centerX, centerY);
    }

    override internal function getSnapToPoint (d :SnappingObject) :Point
    {
        return _point;
    }

    protected var _parent :Sprite;
    protected var _point :Point;
}
}