package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntityComponent;

import flash.display.DisplayObject;

public class DisplayObjectReference extends PushButtonReference
{
    public function DisplayObjectReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }
	
	public function get value () :DisplayObject
	{
		return owner.getProperty(_ref) as DisplayObject;
	}
	
	public function set value (val :DisplayObject) :void
	{
		owner.setProperty(_ref, val);
	}
}
}