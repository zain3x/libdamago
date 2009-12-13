package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponentExtended;
public class ArrayReference extends PushButtonReference
{
    public function ArrayReference (propKey :String, comp :IEntityComponentExtended)
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