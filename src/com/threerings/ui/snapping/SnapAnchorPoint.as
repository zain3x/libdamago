//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObjectContainer;
import flash.geom.Point;

public class SnapAnchorPoint extends SnapAnchor
{
    public function SnapAnchorPoint (d :DisplayObjectContainer, offset :Point = null)
    {
        super(d);
        _offset = offset == null ? new Point() : offset;
    }

    override public function getSnappableDistance (d :ISnappingObject) :Number
    {
        return SnapUtil.getSnappableDistanceFromSnapPointAnchor(this, d, _offset);
    }

    override protected function getGlobalSnapToPoint (d :ISnappingObject) :Point
    {
        return displayObject.localToGlobal(_offset);
    }

    protected var _offset :Point;
}
}