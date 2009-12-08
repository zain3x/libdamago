package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
public class IntegerReference extends PushButtonReference
{
    public function IntegerReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :int
    {
        return _owner.getProperty(_ref) as int;
    }

    public function set value (val :int) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}

