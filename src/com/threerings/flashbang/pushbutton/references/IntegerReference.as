package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
public class IntegerReference extends PushButtonReference
{
    public function IntegerReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }

    public function get value () :int
    {
        return owner.getProperty(_ref) as int;
    }

    public function set value (val :int) :void
    {
        owner.setProperty(_ref, val);
    }
}
}

