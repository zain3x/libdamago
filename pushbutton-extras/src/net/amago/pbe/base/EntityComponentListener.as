package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;
import flash.events.IEventDispatcher;
import com.threerings.util.EventHandlerManager;
public class EntityComponentListener extends EntityComponent
{
	
	override protected function onRemove() : void
	{
		super.onRemove();
		_events.freeAllHandlers();
	}
	
	override protected function onReset() : void
	{
		super.onReset();
		_events.freeAllHandlers();
	}
	
	/**
	 * Adds the specified listener to the specified dispatcher for the specified event.
	 *
	 * Listeners registered in this way will be automatically unregistered when the GameObject is
	 * destroyed.
	 */
	protected function registerListener (dispatcher :IEventDispatcher, event :String,
										 listener :Function, useCapture :Boolean = false, priority :int = 0) :void
	{
		_events.registerListener(dispatcher, event, listener, useCapture, priority);
	}
	
	/**
	 * Registers a zero-arg callback function that should be called once when the event fires.
	 *
	 * Listeners registered in this way will be automatically unregistered when the GameObject is
	 * destroyed.
	 */
	protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
												callback :Function, useCapture :Boolean = false, priority :int = 0) :void
	{
		_events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
	}
	
	/**
	 * Removes the specified listener from the specified dispatcher for the specified event.
	 */
	protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
										   listener :Function, useCapture :Boolean = false) :void
	{
		_events.unregisterListener(dispatcher, event, listener, useCapture);
	}
	
	protected var _events :EventHandlerManager = new EventHandlerManager();
}
}