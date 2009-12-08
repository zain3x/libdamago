package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.PropertyReference;
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