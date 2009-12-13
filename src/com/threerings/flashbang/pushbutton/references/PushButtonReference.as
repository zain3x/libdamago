package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.pushbutton.IEntityExtended;
public class PushButtonReference
{
    public function PushButtonReference (propKey :String, comp :IEntityComponent)
    {
        _ref = new PropertyReference(propKey);
        _component = comp;
    }

    protected function get owner () :IEntityExtended
    {
        return _component.owner;
    }

    protected var _component :IEntityComponent;
    protected var _ref :PropertyReference;
}
}