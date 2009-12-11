package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;
public class ArrayReference extends PushButtonReference
{
    public function ArrayReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :Array
    {
        return _owner.getProperty(_ref) as Array;
    }

    public function set value (val :Array) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}