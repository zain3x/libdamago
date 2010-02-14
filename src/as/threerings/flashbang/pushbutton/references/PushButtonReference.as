package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
public class PushButtonReference
{
    public function PushButtonReference (propKey :String, comp :IEntityComponent)
    {
        _ref = new PropertyReference(propKey);
        _component = comp;
    }

    protected function get owner () :IEntity
    {
        return _component.owner;
    }

    protected var _component :IEntityComponent;
    protected var _ref :PropertyReference;
}
}