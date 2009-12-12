package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntityComponent;
public class StringReference extends PushButtonReference
{
    public function StringReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }

    public function get value () :String
    {
        return owner.getProperty(_ref) as String;
    }

    public function set value (val :String) :void
    {
        owner.setProperty(_ref, val);
    }
}
}