package com.threerings.ui.bounds
{
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

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

    public function distance (p :Point) :Number
    {
        throw new Error("Abstract method");
    }

    public function get width () :Number
    {
        throw new Error("Abstract method");
    }
    public function get height () :Number
    {
        throw new Error("Abstract method");
    }

    public function translate (x :Number, y :Number) :Bounds
    {
        throw new Error("Abstract method");
    }

    public function boundingRect () :Rectangle
    {
        throw new Error("Abstract method");
    }

    public function contains (x :Number, y :Number) :Boolean
    {
        throw new Error("Abstract method");
    }

}
}