package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
public class StringReference extends PushButtonReference
{
    public function StringReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :String
    {
        return _owner.getProperty(_ref) as String;
    }

    public function set value (val :String) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}