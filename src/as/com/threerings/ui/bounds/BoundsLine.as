package com.threerings.ui.bounds {
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.StringUtil;
import net.amago.math.geometry.LineSegment;

public class BoundsLine extends Bounds
{

    public function BoundsLine (x1 :Number, y1 :Number, x2 :Number, y2 :Number)
    {
        _p1 = new Vector2(x1, y1);
        _p2 = new Vector2(x2, y2);
        _lineSegment = new LineSegment(_p1, _p2);
    }

    public function get lineSegment () :LineSegment
    {
        return _lineSegment;
    }

    override public function get center () :Vector2
    {
        return Vector2.interpolate(_p1, _p2, 0.5);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "lineSegment" ]);
    }

    override public function boundingRect () :Rectangle
    {
        var minX :Number = Math.min(_p1.x, _p2.x);
        var maxX :Number = Math.max(_p1.x, _p2.x);
        var minY :Number = Math.min(_p1.y, _p2.y);
        var maxY :Number = Math.max(_p1.y, _p2.y);
        return new Rectangle(minX, minY, maxX - minX, maxY - minY);
    }

    override public function clone () :Object
    {
        return new BoundsLine(_p1.x, _p1.y, _p2.x, _p2.y);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return LineSegment.distToLineSegment(_p1, _p2, new Vector2(x, y)) == 0;
    }

    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        var p1 :Vector2 = Vector2.fromPoint(localDisp.localToGlobal(_p1.toPoint()));
        var p2 :Vector2 = Vector2.fromPoint(localDisp.localToGlobal(_p2.toPoint()));
        return new BoundsLine(p1.x, p1.y, p2.x, p2.y);
    }

    override public function debugDraw (s :Sprite) :void
    {
        s.graphics.lineStyle(2, 0xff0000);
        s.graphics.moveTo(_p1.x, _p1.y);
        s.graphics.lineTo(_p2.x, _p2.y);
    }

    override public function distance (b :Bounds) :Number
    {
        if (b is BoundsPoint) {
            return distanceToPoint(BoundsPoint(b).point);
        } else if (b is BoundsPolygon) {
            return _lineSegment.dist(BoundsPolygon(b).polygon.center);
        } else if (b is BoundsLine) {
            return BoundsLine(b)._lineSegment.distanceToLine(_lineSegment);
        }
        throw new Error("Distance not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));

    }

    override public function distanceToPoint (p :Vector2) :Number
    {
        return LineSegment.distToLineSegment(_p1, _p2, p);
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return LineSegment.closestPoint(_p1, _p2, new Vector2(x, y)).toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number,
        targetX :Number, targetY :Number) :Point
    {
        return getBoundedPoint(targetX, targetY);
    }

    protected var _lineSegment :LineSegment;
    protected var _p1 :Vector2;
    protected var _p2 :Vector2;
}
}
