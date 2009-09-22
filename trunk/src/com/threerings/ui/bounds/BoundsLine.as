package com.threerings.ui.bounds
{

import com.threerings.geom.Vector2;

import flash.display.Graphics;
import flash.geom.Point;

import libdamago.geometry.LineSegment;

public class BoundsLine extends Bounds
{
    public function BoundsLine (x1 :Number, y1 :Number, x2 :Number, y2 :Number)
    {
        _p1 = new Vector2(x1, y1);
        _p2 = new Vector2(x2, y2);
    }

    override public function debugDraw (g :Graphics) :void
    {
        g.lineStyle(2, 0xff0000);
        g.moveTo(_p1.x, _p1.y);
        g.lineTo(_p2.x, _p2.y);
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return LineSegment.closestPoint(_p1, _p2, new Vector2(x, y)).toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        return getBoundedPoint(targetX, targetY);
    }

    override public function distance (p :Point) :Number
    {
        return LineSegment.distToLineSegment(_p1, _p2, Vector2.fromPoint(p));
    }

    override public function translate (dx :Number, dy :Number) :Bounds
    {
        return new BoundsLine(_p1.x + dx, _p1.y + dy, _p2.x + dx, _p2.y + dy);
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return LineSegment.distToLineSegment(_p1, _p2, new Vector2(x, y)) == 0;
    }

    protected var _p1 :Vector2;
    protected var _p2 :Vector2;

}
}