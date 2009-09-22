package com.threerings.ui.bounds
{
import com.threerings.util.MathUtil;
import com.whirled.contrib.debug.DebugUtil;

import flash.display.Graphics;
import flash.geom.Point;

public class BoundsPoint extends Bounds
{
    public function BoundsPoint (x :Number, y :Number)
    {
        _point = new Point(x, y);
    }

    override public function debugDraw (g :Graphics) :void
    {
        DebugUtil.drawDot(g, 0xff0000, 4, _point.x, _point.y);
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

    override public function get width () :Number
    {
        return 0;
    }
    override public function get height () :Number
    {
        return 0;
    }

    protected var _point :Point;

}
}