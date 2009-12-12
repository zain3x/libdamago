package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponent;
public class ArrayReference extends PushButtonReference
{
    public function ArrayReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }

    public function get value () :Array
    {
        return owner.getProperty(_ref) as Array;
    }

    public function set value (val :Array) :void
    {
        owner.setProperty(_ref, val);
    }
}
}