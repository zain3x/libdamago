//
// $Id$

package com.threerings.ui.snapping {
import com.threerings.util.StringUtil;

import flash.geom.Point;
public /*abstract*/ class SnapAnchor
    implements ISnapAnchor
{
    public function SnapAnchor (type :SnapType, idx :int = 0, maxSnapDistance :Number = 20)
    {
        _idx = idx;
        _snapType = type;
        _maxSnapDistance = maxSnapDistance;
    }

    public function get index () :int
    {
        return _idx;
    }

    public function get provider () :Object
    {
        return _provider;
    }

    public function set provider (val :Object) :void
    {
        _provider = val;
    }

    public function get type () :SnapType
    {
        return _snapType;
    }

    public function getSnappableDistance (d :ISnappingObject) :Number
    {
        throw new Error("Abstract method");
    }

//    public function isSnappable (snappable :ISnappingObject) :Boolean
//    {
//        return true;
//    }

    public function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean
    {
        return getSnappableDistance(snappable) <= _maxSnapDistance;
    }

    public function snapObject (snappable :ISnappingObject) :void
    {
        var snapPoint :Point = getGlobalSnapToPoint(snappable);
        SnapUtil.snapCenterOfBoundsToGlobalPoint(snappable, snapPoint);
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, ["type", "index"]);
    }

    protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        throw new Error("Abstract method");
    }

    protected var _idx :int;
    protected var _maxSnapDistance :Number;

    protected var _provider :Object;
    protected var _snapType :SnapType;
}
}