package com.threerings.ui.snapping
{
import flash.events.Event;

public class SnapEvent extends Event
{
    public function SnapEvent (axis :SnapAxis, anchor :Object, snapped :Object)
    {
        super(SNAP_EVENT, false, false);
        this.anchor = anchor;
        this.snapped = snapped;
        this.axis = axis;
    }

    public var anchor :Object;
    public var snapped :Object;
    public var axis :SnapAxis;

    public static const SNAP_EVENT :String = "snapEvent";
}
}