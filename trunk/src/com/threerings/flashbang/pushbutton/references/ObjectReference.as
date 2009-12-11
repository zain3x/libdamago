package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;
public class ObjectReference extends PushButtonReference
{
    public function ObjectReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :*
    {
        return _owner.getProperty(_ref);
    }

    public function set value (val :*) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}