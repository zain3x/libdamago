package libdamago.pushbutton.components {
import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.geom.Point;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;
public class LocationComponent extends EntityComponentEfficientDispatcher
	implements IEventDispatcher
{
	public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(LocationComponent);
	public static const EVENT_NAME :String = "locationChanged";
	
	public function get point () :Point
	{
		return new Point(_x, _y);
	}
	
	public function set point (p :Point) :void
	{
		if (_x != p.x || _y != p.y) {
			_x = p.x;
			_y = p.y;
			if (_efficientDispatcher != null) {
				dispatchEvent(event);
			}
		}
	}
	
	public function get x () :Number
	{
		return _x;
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
	
	public function get y () :Number
	{
		return _y;
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
	
	public function setLocation (xLoc :Number, yLoc :Number) :void
	{
		if (_x != xLoc || _y != yLoc) {
			_x = xLoc;
			_y = yLoc;
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
	
	protected var _event :Event;
	
	protected var _x :Number = 0;
	protected var _y :Number = 0;
	protected static const log :Log = Log.getLog(LocationComponent);
}
}