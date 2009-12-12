package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;

import flash.geom.Rectangle;
public class RectangleReference extends PushButtonReference
{
    public function RectangleReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :Rectangle
    {
        return _owner.getProperty(_ref) as Rectangle;
    }

    public function set value (val :Rectangle) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}