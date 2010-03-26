package com.threerings.ui.snapping {
import flash.events.Event;
import com.threerings.util.StringUtil;

public class SnapEvent extends Event
{

    public static const SNAP_EVENT :String = "snapEvent";

    public var anchor :ISnapAnchor;
    public var axis :SnapDirection;
    public var snapped :ISnappingObject;

    public function SnapEvent (anchor :ISnapAnchor, snapped :ISnappingObject, axis :SnapDirection =
        null)
    {
        super(SNAP_EVENT, false, false);
        this.anchor = anchor;
        this.snapped = snapped;
        this.axis = axis;
    }

    override public function toString () :String
    {
        return StringUtil.simpleToString(this, [ "anchor", "snapped" ]);
    }
}
}
