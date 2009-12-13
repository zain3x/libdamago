package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponentExtended;
public class FunctionReference extends PushButtonReference
{
    public function FunctionReference (propKey :String, comp :IEntityComponentExtended)
    {
        super(propKey, comp);
    }

    public function get value () :Function
    {
        return owner.getProperty(_ref) as Function;
    }

    public function set value (val :Function) :void
    {
        owner.setProperty(_ref, val);
    }
}
}