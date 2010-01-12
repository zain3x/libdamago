package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.events.Event;

//This is more of a hassle than it's worth, will remove in the future.
public class SceneComponent extends EntityComponent
{
	public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SceneComponent);
	public static const CHANGED :String = COMPONENT_NAME + "Changed";
	
	public function SceneComponent (disp :DisplayObject = null)
	{
		_displayObject = disp;
	}
	
	public function get displayObject () :DisplayObject
	{
		return _displayObject;
	}
	
	public function changed () :void
	{
		owner.eventDispatcher.dispatchEvent(_event);
	}
	
	protected var _displayObject :DisplayObject;
	protected var _event :Event = new Event(CHANGED);
}
}