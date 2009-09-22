package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;
import com.whirled.contrib.debug.DebugUtil;

import flash.display.Graphics;
import flash.geom.Point;

public class BoundsPoint extends Bounds
{
    public function BoundsPoint (x :Number, y :Number)
    {
        _point = new Vector2(x, y);
    }

    override public function debugDraw (g :Graphics) :void
    {
        DebugUtil.drawDot(g, 0xff0000, 4, _point.x, _point.y);
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return _point.toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        return _point.toPoint();
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

    override public function translate (dx :Number, dy :Number) :Bounds
    {
        return new BoundsPoint(_point.x + dx, _point.y + dy);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return _point.x == x && _point.y == y;
    }

    protected var _point :Vector2;

}
}