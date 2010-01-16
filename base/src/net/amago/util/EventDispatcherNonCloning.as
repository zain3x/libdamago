package net.amago.util {
	import com.threerings.util.ArrayUtil;
	import com.threerings.util.ClassUtil;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * Different implementation of IEventDispatcher.  Events are not cloned, so can safely be 
	 * reused, greatly improving performance.
	 * 
	 * Not used: priority and weak references (all references are hard).
	 * 
	 * 
	 */
	public class EventDispatcherNonCloning implements IEventDispatcher
	{
		public function addEventListener (type :String, listener :Function, useCapture :Boolean = false,
										  priority :int = 0, useWeakReference :Boolean = false) :void
		{
			if (listener == null) {
				throw new ArgumentError("listener is null");
			}
			
			if (type == null || type == "") {
				throw new ArgumentError("type is emtpy");
			}
			
			var listeners :Array = _eventListeners[type] as Array; 
			if (listeners == null) {
				listeners = new Array();
				_eventListeners[type] = listeners;
			}
			
			if (!ArrayUtil.contains(listeners, listener)) {
				listeners.push(listener);
			}
			
			//		var listeners :Listeners = _eventListeners[type] as Listeners; 
			//		if (listeners == null) {
			//			listeners = new Listeners();
			//			_eventListeners[type] = listeners;
			//		}
			//		
			//		var dict :Dictionary = useWeakReference ? listeners.weakRefs : listeners.strongRefs;
			//		dict[listener] = true;
		}
		
		
		
		public function dispatchEvent (event :Event) :Boolean
		{
			if (event == null) {
				throw new ArgumentError("dispatchEvent, event==null");
			}
			
			var listeners :Array = _eventListeners[event.type] as Array;
			if (listeners == null) {
				return true;
			}
			
			for each (var k :Function in listeners) { // no "each": iterate over keys
				if (k != null) {
					k.call(undefined, event);
				}
			}
			return true;
			
			//		var listeners :Listeners = _eventListeners[type] as Listeners;
			//		if (listeners == null) {
			//			return true;
			//		}
			//		
			//		for (var k :Function in listeners.strongRefs) { // no "each": iterate over keys
			//			k.apply(, undefined, event);
			//		}
			//		for (var k :Function in listeners.weakRefs) { // no "each": iterate over keys
			//			if (k. != null) {
			//				k.apply(undefined, event);
			//			}
			//		}
			//        return true;
		}
		
		public function hasEventListener (type :String) :Boolean
		{
			return _eventListeners[type] != null;
		}
		
		public function removeEventListener (type :String, listener :Function, useCapture :Boolean =
											 false) :void
		{
			var listeners :Array = _eventListeners[type] as Array;
			if (listeners == null) {
				return;
			}
			ArrayUtil.removeFirst(listeners, listener);
			
			
			//		var listeners :Listeners = _eventListeners[type] as Listeners;
			//		if (listeners == null) {
			//			return;
			//		}
			//		delete listeners.strongRefs[listener];
			//		delete listeners.weakRefs[listener];
		}
		
		public function willTrigger (type :String) :Boolean
		{
			return hasEventListener(type);
		}
		
		public function toString () :String
		{
			return ClassUtil.tinyClassName(this);
		}
		
		protected var _eventListeners :Dictionary = new Dictionary();
		
		
	}
}
//import flash.utils.Dictionary;
//
//class Listeners
//{
//	public var strongRefs :Dictionary = new Dictionary(false);//Strong keys
//	public var weakRefs :Dictionary = new Dictionary(true);//Weak keys
//}

