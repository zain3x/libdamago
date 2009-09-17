//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
public /*abstract*/ class SnapAnchor
    implements ISnapAnchor
{
    public function SnapAnchor (displayObject : DisplayObjectContainer,
        maxSnapDistance :Number = 20)
    {
        _displayObject = displayObject;
        _maxSnapDistance = maxSnapDistance;
    }

    public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    public function get displayContainer () :DisplayObjectContainer
    {
        return _displayObject;
    }

    public function getSnappableDistance (d :ISnappingObject) :Number
    {
        throw new Error("Abstract method");
    }

    protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        throw new Error("Abstract method");
    }

    public function isSnappable (snappable :ISnappingObject) :Boolean
    {
        return true;
    }

    public function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean
    {
        return getSnappableDistance(snappable) <= _maxSnapDistance;
    }

    public function snapObject (snappable :ISnappingObject) :void
    {
        var snapPoint :Point = getGlobalSnapToPoint(snappable);
        SnapUtil.snapCenterOfBoundsToGlobalPoint(snappable, snapPoint);
//        snappable.snapCenterOfBoundsToPoint(snapPoint);
    }

//    internal function get dataObj () :Object
//    {
//        return _dataObj;
//    }

//    protected var _dataObj :Object;
    protected var _displayObject :DisplayObjectContainer;
    protected var _maxSnapDistance :Number;
//    protected var _snapType :SnapType;

}
}