package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntityComponent;

public class NumberReference extends PushButtonReference
{
    public function NumberReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }

    public function get value () :Number
    {
        return owner.getProperty(_ref) as Number;
    }

    public function set value (val :Number) :void
    {
        owner.setProperty(_ref, val);
    }
}
}