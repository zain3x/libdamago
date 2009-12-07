package com.threerings.flashbang.pushbutton.scene.components {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.flashbang.components.LocationComponent;
//For debugging purposes
public class LocationComponentBasic extends EntityComponent implements LocationComponent
{
    public function LocationComponentBasic ()
    {
        super();
    }

    public function get x () :Number
    {
        return _x;
    }

    public function set x (val :Number) :void
    {
        _x = val;
    }

    public function get y () :Number
    {
        return _y;
    }

    public function set y (val :Number) :void
    {
        _y = val;
    }

    protected var _x :Number = 0;
    protected var _y :Number = 0;
}
}