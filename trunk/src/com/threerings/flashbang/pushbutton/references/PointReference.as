package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponentExtended;

import flash.geom.Point;
public class PointReference extends PushButtonReference
{
    public function PointReference (propKey :String, comp :IEntityComponentExtended)
    {
        super(propKey, comp);
    }

    public function get value () :Point
    {
        return owner.getProperty(_ref) as Point;
    }

    public function set value (val :Point) :void
    {
        owner.setProperty(_ref, val);
    }
}
}