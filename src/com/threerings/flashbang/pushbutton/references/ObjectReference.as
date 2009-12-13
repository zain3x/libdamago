package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponentExtended;
public class ObjectReference extends PushButtonReference
{
    public function ObjectReference (propKey :String, comp :IEntityComponentExtended)
    {
        super(propKey, comp);
    }

    public function get value () :*
    {
        return owner.getProperty(_ref);
    }

    public function set value (val :*) :void
    {
        owner.setProperty(_ref, val);
    }
}
}