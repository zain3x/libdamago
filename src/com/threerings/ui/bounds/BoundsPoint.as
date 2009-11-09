package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;
import com.threerings.util.DebugUtil;

import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BoundsPoint extends Bounds
{
    public function BoundsPoint (x :Number, y :Number)
    {
        _point = new Vector2(x, y);
    }

    override public function debugDraw (s :Sprite) :void
    {
        DebugUtil.drawDot(s, 0xff0000, 4, _point.x, _point.y);
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

    override public function distanceToPoint (p :Vector2) :Number
    {
        return MathUtil.distance(p.x, p.y, _point.x, _point.y);
    }

    override public function distance (b :Bounds) :Number
    {
//        log.debug("distance " + ClassUtil.tinyClassName(this) +
//        " and " + ClassUtil.tinyClassName(b));
        if (b is BoundsPoint) {
            return distanceToPoint(BoundsPoint(b).point);
        } else if (b is BoundsPolygon) {
//            return BoundsPolygon(b).polygon.distToPolygonEdge(_point);
            return distanceToPoint(BoundsPolygon(b).polygon.center);
        } else if (b is BoundsLine) {
            return BoundsLine(b).lineSegment.dist(_point);
        }
        throw new Error("Distance not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));

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

    override public function scale (scaleX :Number, scaleY :Number) :Bounds
    {
        return new BoundsPoint(_point.x * scaleX, _point.y * scaleY);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return _point.x == x && _point.y == y;
    }

    override public function boundingRect () :Rectangle
    {
        return new Rectangle(_point.x, _point.y, 0, 0);
    }

    public function get point () :Vector2
    {
        return _point;
    }

    override public function get center () :Vector2
    {
        return _point;
    }

    protected var _point :Vector2;
    protected static const log :Log = Log.getLog(BoundsPoint);
}
}
