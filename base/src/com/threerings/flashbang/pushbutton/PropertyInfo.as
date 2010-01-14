package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntityComponent;
import flash.events.IEventDispatcher;
import com.threerings.flashbang.Updatable;
import com.threerings.util.ArrayUtil;
import com.threerings.util.DebugUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
final public class PropertyInfo
{
    public var propertyName :String = null;
    public var propertyParent :Object = null;

    public function clear () :void
    {
        propertyParent = null;
        propertyName = null;
    }

    public function getValue () :*
    {
        try {
            if (propertyName)
                return propertyParent[propertyName];
            else
                return propertyParent;
        } catch (e :Error) {
            return null;
        }
    }

    public function setValue (value :*) :void
    {
        propertyParent[propertyName] = value;
    }
}
}