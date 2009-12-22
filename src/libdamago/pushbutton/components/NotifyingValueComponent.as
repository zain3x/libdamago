package libdamago.pushbutton.components {
import com.threerings.util.ValueEvent;
public class NotifyingValueComponent extends EntityComponentEfficientDispatcher
{
    public function setValue (val :Number) :void
    {
        if (_value != val) {
            _value = val;
            if (_efficientDispatcher != null) {
                dispatchEvent(event);
            }
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