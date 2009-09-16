//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;
import flash.geom.Point;
public /*abstract*/ class SnapAnchor
{
    public function SnapAnchor (type :SnapType, displayObject : DisplayObject, maxSnapDistance :Number = 20)
    {
//        _snapType = type;
        _displayObject = displayObject;
        _maxSnapDistance = maxSnapDistance;
    }

    internal function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    internal function getSnappableDistance (d :SnappingObject) :Number
    {
        throw new Error("Abstract method");
    }

    internal function getSnapToPoint (d :SnappingObject) :Point
    {
        throw new Error("Abstract method");
    }

    internal function isSnappable (snappable :SnappingObject) :Boolean
    {
        return getSnappableDistance(snappable) <= _maxSnapDistance;
    }

    protected var _displayObject :DisplayObject;
    protected var _maxSnapDistance :Number;
//    protected var _snapType :SnapType;

}
}