package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;
public class Bounds
{

    public static function centerBounds (disp :DisplayObject, localBounds :Bounds, x :Number,
        y :Number) :void
    {
        var boundingRect :Rectangle = localBounds.boundingRect();
        positionBounds(disp, localBounds, x - boundingRect.width / 2, y - boundingRect.height / 2);

    }

    public static function convertToGlobal (localBounds :Bounds, localDisp :DisplayObject) :Bounds
    {
        var globalTranslate :Point = localDisp.localToGlobal(new Point(0, 0));
        return localBounds.translate(globalTranslate.x, globalTranslate.y);

    }

    public static function positionBounds (disp :DisplayObject, localBounds :Bounds, x :Number,
        y :Number) :void
    {
        var boundingRect :Rectangle = localBounds.boundingRect();
        disp.x = x - boundingRect.left;
        disp.y = y - boundingRect.top;
    }
    public function get height () :Number
    {
        throw new Error("Abstract method");
    }

    public function get width () :Number
    {
        throw new Error("Abstract method");
    }

    public function boundingRect () :Rectangle
    {
        throw new Error("Abstract method missing from " + ClassUtil.tinyClassName(this));
    }

    public function contains (x :Number, y :Number) :Boolean
    {
        throw new Error("Abstract method");
    }

    public function debugDraw (g :Graphics) :void
    {
        throw new Error("Abstract method");
    }

    public function distanceToPoint (p :Vector2) :Number
    {
        throw new Error("Abstract method");
    }

    public function distance (b :Bounds) :Number
    {
        throw new Error("Abstract method");
    }

//    public function enforceBounds (d :DisplayObject) :void
//    {
//        var boundedPoint :Point = getBoundedPoint(d.x, d.y);
//        d.x = boundedPoint.x;
//        d.y = boundedPoint.y;
//    }

    public function getBoundedPoint (x :Number, y :Number) :Point
    {
        throw new Error("Abstract method");
    }

    public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        throw new Error("Abstract method");
    }

    public function translate (x :Number, y :Number) :Bounds
    {
        throw new Error("Abstract method");
    }
}
}