package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;
import com.threerings.flashbang.pushbutton.PropertyReference;
public class PushButtonReference
{
    public function PushButtonReference (propKey :String, owner :IEntity)
    {
        _ref = new PropertyReference(propKey);
        _owner = owner;
    }

    protected var _owner :IEntity;
    protected var _ref :PropertyReference;
}
}