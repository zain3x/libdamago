package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.IEntity;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.ValueEvent;

import flash.events.Event;
import flash.geom.Point;

public class LocationComponent extends EntityComponent
{
    public static const CHANGED :String = "locationChanged";
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(LocationComponent);

    public static function getFrom (e :IEntity) :LocationComponent
    {
        return e.lookupComponentByName(COMPONENT_NAME) as LocationComponent;
    }

    public function get point () :Point
    {
        return new Point(_x, _y);
    }

    public function set point (p :Point) :void
    {
        if (_x != p.x && _y != p.y) {
            _x = p.x;
            _y = p.y;
            if (owner != null) {
                owner.eventDispatcher.dispatchEvent(event);
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
            if (owner != null) {
                owner.eventDispatcher.dispatchEvent(event);
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
            if (owner != null) {
                owner.eventDispatcher.dispatchEvent(event);
            }
        }
    }

    public function setLocation (xLoc :Number, yLoc :Number) :void
    {
        if (_x != xLoc && _y != yLoc) {
            _x = xLoc;
            _y = yLoc;
            if (owner != null) {
                owner.eventDispatcher.dispatchEvent(event);
            }
        }
    }

    public function toString () :String
    {
        return "[Location " + x + ", " + y + "]";
    }

    protected function get event () :Event
    {
        if (_event == null) {
            _event = new ValueEvent(CHANGED, this);
        }
        return _event;
    }

    protected var _event :Event;

    protected var _x :Number = 0;
    protected var _y :Number = 0;
    protected static const log :Log = Log.getLog(LocationComponent);
}
}