package com.threerings.flashbang.pushbutton.scene.components {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.flashbang.components.LocationComponent;
public class LocationComponentLoopback extends EntityComponent
    implements LocationComponent
{

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