package com.threerings.flashbang.pushbutton.scene.components {
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.pushbutton.EntityComponentEventManager;
//For debugging purposes
public class LocationComponentBasic extends EntityComponentEventManager
    implements LocationComponent
{
    public static const COMPONENT_NAME :String = "location";

    public function LocationComponentBasic ()
    {
        super();
    }

    override public function get name () :String
    {
        return COMPONENT_NAME;
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