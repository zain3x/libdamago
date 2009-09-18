package com.threerings.ui.bounds
{
import com.threerings.util.MathUtil;
import com.whirled.contrib.debug.DebugUtil;

import flash.display.Graphics;
import flash.geom.Point;

public class BoundsPoint extends Bounds
{
    public function BoundsPoint (p :Point)
    {
        _point = p;
    }

    override public function debugDraw (g :Graphics) :void
    {
        DebugUtil.drawDot(g, 0, 0xff0000, 4);
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return _point;
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        return _point;
    }

    override public function distance (p :Point) :Number
    {
        return MathUtil.distance(p.x, p.y, _point.x, _point.y);
    }

    protected var _point :Point;

}
}