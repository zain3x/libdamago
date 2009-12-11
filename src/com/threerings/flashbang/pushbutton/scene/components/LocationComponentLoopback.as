package com.threerings.flashbang.pushbutton.scene.components {
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.pushbutton.EntityComponent;
public class LocationComponentLoopback extends EntityComponent
    implements LocationComponent
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
    }

    public function get y () :Number
    {
        return _loc.y;
    }

    public function set y (val :Number) :void
    {
        _loc.y = val;
    }

    protected var _loc :LocationComponent;
}
}