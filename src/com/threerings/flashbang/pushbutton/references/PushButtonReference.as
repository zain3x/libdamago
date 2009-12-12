package com.threerings.flashbang.pushbutton.references {
import com.threerings.flashbang.pushbutton.IEntity;
import com.threerings.flashbang.pushbutton.IEntityComponent;
import com.threerings.flashbang.pushbutton.PropertyReference;
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