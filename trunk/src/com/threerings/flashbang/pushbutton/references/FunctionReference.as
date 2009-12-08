package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
public class FunctionReference extends PushButtonReference
{
    public function FunctionReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :Function
    {
        return _owner.getProperty(_ref) as Function;
    }

    public function set value (val :Function) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}