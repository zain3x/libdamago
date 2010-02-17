package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;

import flash.events.Event;
import flash.events.IEventDispatcher;

import libdamago.events.EventDispatcherNonCloning;

public class EntityComponentEfficientDispatcher extends EntityComponent
	implements IEventDispatcher
{
	public function EntityComponentEfficientDispatcher () 
	{
	}
	
	public function addEventListener (type :String, listener :Function, useCapture :Boolean = false,
									  priority :int = 0, useWeakReference :Boolean = false) :void
	{
		
		dispatcher.addEventListener(type, listener, useCapture, priority, useWeakReference);
	}
	
	public function dispatchEvent (event :Event) :Boolean
	{
		return dispatcher.dispatchEvent(event);
	}
	
	public function hasEventListener (type :String) :Boolean
	{
		return dispatcher.hasEventListener(type);
	}
	
	public function removeEventListener (type :String, listener :Function, useCapture :Boolean =
										 false) :void
	{
		dispatcher.removeEventListener(type, listener, useCapture);
	}
	
	public function willTrigger (type :String) :Boolean
	{
		return dispatcher.willTrigger(type);
	}
	
	protected function get dispatcher () :IEventDispatcher
	{
		//Lazily create, since we might not ever use it.
		if (_efficientDispatcher == null) {
			_efficientDispatcher = new EventDispatcherNonCloning();
		}
		return _efficientDispatcher;
	}
	
	protected var _efficientDispatcher :IEventDispatcher;
}
}
