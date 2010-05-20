package com.threerings.ui.bounds
{

import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class BoundsNone extends Bounds
{
    public function BoundsNone()
    {
        super();
    }

    override public function get height () :Number
    {
        return 0;
    }

    override public function get width () :Number
    {
        return 0;
    }

    override public function get center () :Vector2
    {
        throw new Error("Abstract method");
    }

    override public function boundingRect () :Rectangle
    {
        throw new Error("Abstract method missing from " + ClassUtil.tinyClassName(this));
    }

    override public function clone () :Object
    {
        return new BoundsNone();
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        return true;
    }

    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        throw new Error("Abstract method");
    }

    override public function debugDraw (s :Sprite) :void
    {
        throw new Error("Abstract method");
    }

    override public function distance (b :Bounds) :Number
    {
        return 0;
    }

    override public function distanceToPoint (p :Vector2) :Number
    {
        return 0;
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return new Point(x,y);
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
                                                      targetY :Number) :Point
    {
        throw new Error("Abstract method");
    }
}
}