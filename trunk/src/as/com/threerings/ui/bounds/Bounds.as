package com.threerings.ui.bounds {
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.Cloneable;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

public class Bounds implements Cloneable
{


    public static function centerBounds (disp :DisplayObject, localBounds :Bounds, x :Number,
        y :Number) :void
    {
        var boundingRect :Rectangle = localBounds.boundingRect();
        positionBounds(disp, localBounds, x - boundingRect.width / 2, y - boundingRect.height / 2);

    }

    public static function convertToGlobal (localBounds :Bounds, localDisp :DisplayObject) :Bounds
    {
        if (localBounds == null || localDisp == null) {
            throw new Error("localBounds=" + localBounds + ", localDisp=" + localDisp);
        }
        return localBounds.convertToGlobal(localDisp);
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

    public function get center () :Vector2
    {
        throw new Error("Abstract method");
    }

    public function boundingRect () :Rectangle
    {
        throw new Error("Abstract method missing from " + ClassUtil.tinyClassName(this));
    }

    public function clone () :Object
    {
        throw new Error("Abstract method");
    }

    public function contains (x :Number, y :Number) :Boolean
    {
        throw new Error("Abstract method");
    }

    public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        throw new Error("Abstract method");
    }

    public function debugDraw (s :Sprite) :void
    {
        throw new Error("Abstract method");
    }

    public function distance (b :Bounds) :Number
    {
        throw new Error("Abstract method");
    }

    public function distanceToPoint (p :Vector2) :Number
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
//import com.threerings.geom.Vector2;
//import com.threerings.ui.bounds.Bounds;
//import com.threerings.util.ClassUtil;
//
//import flash.display.DisplayObject;
//import flash.display.Sprite;
//import flash.geom.Point;
//import flash.geom.Rectangle;
//
//class NoBounds extends Bounds
//{
//    override public function get height () :Number
//    {
//        return 0;
//    }
//
//    override public function get width () :Number
//    {
//        return 0;
//    }
//
//    override public function get center () :Vector2
//    {
//        throw new Error("Abstract method");
//    }
//
//    override public function boundingRect () :Rectangle
//    {
//        throw new Error("Abstract method missing from " + ClassUtil.tinyClassName(this));
//    }
//
//    override public function clone () :Object
//    {
//        return new NoBounds();
//    }
//
//    override public function contains (x :Number, y :Number) :Boolean
//    {
//        return true;
//    }
//
//    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
//    {
//        throw new Error("Abstract method");
//    }
//
//    override public function debugDraw (s :Sprite) :void
//    {
//        throw new Error("Abstract method");
//    }
//
//    override public function distance (b :Bounds) :Number
//    {
//        return 0;
//    }
//
//    override public function distanceToPoint (p :Vector2) :Number
//    {
//        return 0;
//    }
//
//    override public function getBoundedPoint (x :Number, y :Number) :Point
//    {
//        return new Point(x,y);
//    }
//
//    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
//                                             targetY :Number) :Point
//    {
//        throw new Error("Abstract method");
//    }
//}
