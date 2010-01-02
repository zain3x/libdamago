package com.threerings.flashbang.pushbutton.scene.components {
import com.threerings.flashbang.pushbutton.EntityComponentEventManager;
import com.threerings.flashbang.components.LocationComponent;

import flash.events.Event;

import libdamago.pushbutton.components.LocationComponent;

public class LocationComponentLoopback extends EntityComponentEventManager
    implements com.threerings.flashbang.components.LocationComponent
{
    public static const COMPONENT_NAME :String = "location";

    override public function get name () :String
    {
        return COMPONENT_NAME;
    }

    public function LocationComponentLoopback (loc :LocationComponent)
    {
        _loc = loc;
    }

    public function get x () :Number
    {
        return _loc.x;
    }

    public function set x (val :Number) :void
    {
        _loc.x = val;
		trace("avatar is changing x");
		owner.eventDispatcher.dispatchEvent(_event);
    }

    public function get y () :Number
    {
        return _loc.y;
    }

    public function set y (val :Number) :void
    {
        _loc.y = val;
		owner.eventDispatcher.dispatchEvent(_event);
    }

    protected var _loc :LocationComponent;
	protected var _event :Event = new Event(libdamago.pushbutton.components.LocationComponent.EVENT_LOCATION_CHANGED);
}
}