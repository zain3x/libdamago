package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;
public class PointReference extends PushButtonReference
{
    public function PointReference (propKey :String, owner :IEntity)
    {
        super(propKey, owner);
    }

    public function get value () :Point
    {
        return _owner.getProperty(_ref) as Point;
    }

    public function set value (val :Point) :void
    {
        _owner.setProperty(_ref, val);
    }
}
}