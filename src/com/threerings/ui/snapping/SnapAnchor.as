//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;
import flash.geom.Rectangle;
public /*abstract*/ class SnapAnchor
    implements ISnapAnchor
{
    public function SnapAnchor (type :SnapType, maxSnapDistance :Number = 20)
    {
        _snapType = type;
//        _displayObject = displayObject;
        _maxSnapDistance = maxSnapDistance;
    }

//    public function get globalBounds () :Rectangle
//    {
//        return _displayObject;
//    }

//    public function get displayContainer () :DisplayObjectContainer
//    {
//        return _displayObject;
//    }

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

    public function get type () :SnapType
    {
        return _snapType;
    }

    public function get provider () :Object
    {
        return _provider;
    }

    public function set provider (val :Object) :void
    {
        _provider = val;
    }

//    internal function get dataObj () :Object
//    {
//        return _dataObj;
//    }

    protected var _provider :Object;
    protected var _displayObject :Rectangle;
    protected var _maxSnapDistance :Number;
    protected var _snapType :SnapType;

}
}