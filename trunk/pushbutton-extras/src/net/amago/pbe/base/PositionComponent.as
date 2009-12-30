package net.amago.pbe.base {
import com.threerings.util.ValueEvent;

import flash.events.Event;
import flash.events.IEventDispatcher;

public class PositionComponent extends EntityComponentEfficientDispatcher
	implements IEventDispatcher
{
	public static const EVENT_NAME :String = "locationChanged";
	public static const COMPONENT_NAME :String = "locationComponent";
	
	public function get x () :Number
	{
		return _x;
	}
	
	public function get y () :Number
	{
		return _y;
	}
	
	public function set x (val :Number) :void
	{
		if (_x != val) {
			_x = val;
			if (_efficientDispatcher != null) {
				dispatchEvent(event);
			}
		}
	}
	
	public function setLocation (x :Number, y :Number) :void
	{
		if (_x != x || _y != val) {
			_x = x;
			_y = y;
			if (_efficientDispatcher != null) {
				dispatchEvent(event);
			}
		}
	}
	
	public function set y (val :Number) :void
	{
		if (_y != val) {
			_y = val;
			if (_efficientDispatcher != null) {
				dispatchEvent(event);
			}
		}
	}
	
	protected function get event () :Event
	{
		if (_event == null) {
			_event = new ValueEvent(EVENT_NAME, this);
		}
		return _event;
	}
	
	protected var _x :Number = 0;
	protected var _y :Number = 0;
	
	protected var _event :Event;
}
}