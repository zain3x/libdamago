package com.threerings.ui.snapping
{
import com.threerings.util.StringUtil;

import flash.events.Event;

public class SnapEvent extends Event
{
    public function SnapEvent (anchor :ISnapAnchor, snapped :ISnappingObject,
        axis :SnapDirection = null)
    {
        super(SNAP_EVENT, false, false);
        this.anchor = anchor;
        this.snapped = snapped;
        this.axis = axis;
    }

    override public function toString () :String
    {
        return StringUtil.simpleToString(this, ["anchor", "snapped"]);
    }

    public var anchor :ISnapAnchor;
    public var snapped :ISnappingObject;
    public var axis :SnapDirection;

    public static const SNAP_EVENT :String = "snapEvent";
}
}