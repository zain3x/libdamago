package com.threerings.ui.bounds
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Point;

public class Bounds
{
    public function enforceBounds (d :DisplayObject) :void
    {
        var boundedPoint :Point = getBoundedPoint(d.x, d.y);
        d.x = boundedPoint.x;
        d.y = boundedPoint.y;
    }

    public function debugDraw (g :Graphics) :void
    {
        throw new Error("Abstract method");
    }

    public function getBoundedPoint (x :Number, y :Number) :Point
    {
        throw new Error("Abstract method");
    }

    public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        throw new Error("Abstract method");
    }
}
}