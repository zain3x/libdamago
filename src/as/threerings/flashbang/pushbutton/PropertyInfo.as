package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntity;

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
            if (propertyName) {
				if (propertyParent is IEntity) {
					return IEntity(propertyParent).lookupComponentByName(propertyName);			
				} else {
	                return propertyParent[propertyName];
				}
			}
            else {
                return propertyParent;
			}
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