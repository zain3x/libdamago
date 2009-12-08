package com.threerings.flashbang.pushbutton.references {
public class NumberReference
{
    public function NumberReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :Number
    {
        return _owner.getProperty(_ref) as Number;
    }

    public function set value (val :Number) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}