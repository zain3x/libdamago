package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponentExtended;

import flash.geom.Rectangle;
public class RectangleReference extends PushButtonReference
{
    public function RectangleReference (propKey :String, comp :IEntityComponentExtended)
    {
        super(propKey, comp);
    }

    public function get value () :Rectangle
    {
        return owner.getProperty(_ref) as Rectangle;
    }

    public function set value (val :Rectangle) :void
    {
        owner.setProperty(_ref, val);
    }
}
}