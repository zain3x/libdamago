package com.threerings.flashbang.pushbutton.references {
import com.pblabs.engine.entity.IEntityComponent;
public class ClassReference extends PushButtonReference
{
    public function ClassReference (propKey :String, comp :IEntityComponent)
    {
        super(propKey, comp);
    }
	
	public function get value () :Class
	{
		return owner.getProperty(_ref) as Class;
	}
	
	public function set value (val :Class) :void
	{
		owner.setProperty(_ref, val);
	}
}
}