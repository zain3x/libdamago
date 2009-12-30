package libdamago.pushbutton.components {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.util.ValueEvent;

import flash.events.Event;

public class NotifyingValueComponent extends EntityComponent
{
    public function setValue (val :Number) :void
    {
		_value = val;
		if (owner != null) {
			owner.eventDispatcher.dispatchEvent(event);
		}
    }

    protected function get event () :Event
    {
        if (_event == null) {
            _event = new ValueEvent(eventName, this);
        }
        return _event;
    }

    protected function get eventName () :String
    {
        throw new Error("Abstract method, override");
    }
    protected var _event :Event;
    protected var _value :Number = 0;
}
}