//
// $Id$

package com.threerings.ui.snapping {
import flash.geom.Point;
import com.threerings.ui.bounds.Bounds;
import com.threerings.util.StringUtil;

public /*abstract*/class SnapAnchor implements ISnapAnchor
{
    public function SnapAnchor (idx :int = -1, maxSnapDistance :Number = 20)
    {
        _idx = idx;
        _maxSnapDistance = maxSnapDistance;
    }

    public function get userData () :*
    {
        return _userData;
    }

    public function get bounds () :Bounds
    {
        throw new Error("Abstract method");
    }

    public function get snapDistance () :Number
    {
        return _maxSnapDistance;
    }

    public function get provider () :Object
    {
        return _provider;
    }

    public function get index () :int
    {
        return _idx;
    }

    public function set provider (val :Object) :void
    {
        _provider = val;
    }

    public function set userData (val :*) :void
    {
        _userData = val;
    }

    public function getSnappableDistance (d :ISnappingObject) :Number
    {
        throw new Error("Abstract method");
    }

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
        return StringUtil.simpleToString(this, [ "index", "userData", "provider" ]);
    }

    protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        throw new Error("Abstract method");
    }

    protected var _idx :int;
    protected var _maxSnapDistance :Number;

    protected var _provider :Object;

    protected var _userData :*;
}
}
