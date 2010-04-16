package net.amago.util {
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;

import flash.events.Event;
import flash.events.IEventDispatcher;
import flash.utils.Dictionary;

/**
 * Different implementation of IEventDispatcher.  Events are not cloned, so can safely be
 * reused, greatly improving performance.
 *
 * Not used: priority and weak references (all references are hard).
 *
 * Use with EventHandlerManager to ensure anonymous functions are GC'ed.
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

        if (useWeakReference) {
            log.warning("addEventListener: weak references not used.");
        }

        if (priority != 0) {
            log.warning("addEventListener: priority ignored.");
        }

        if (_eventListeners == null) {
            _eventListeners = new Dictionary();
        }

        var listeners :Array = _eventListeners[type] as Array;
        if (listeners == null) {
            listeners = new Array();
            _eventListeners[type] = listeners;
        }

        if (!ArrayUtil.contains(listeners, listener)) {
            listeners.push(listener);
        }
    }

    public function dispatchEvent (event :Event) :Boolean
    {
        if (event == null) {
            throw new ArgumentError("dispatchEvent, event==null");
        }

        if (_eventListeners == null) {
            return false;
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
    }

    public function hasEventListener (type :String) :Boolean
    {
        return _eventListeners  != null && _eventListeners[type] != null &&
            (_eventListeners[type] as Array).length > 0;
    }

    public function removeEventListener (type :String, listener :Function, useCapture :Boolean =
        false) :void
    {
        if (_eventListeners == null) {
            return;
        }
        var listeners :Array = _eventListeners[type] as Array;
        if (listeners == null) {
            return;
        }
        ArrayUtil.removeFirst(listeners, listener);
    }

    public function toString () :String
    {
        if (_eventListeners == null) {
            return ClassUtil.tinyClassName(this) + ", no event listeners";
        }
        return ClassUtil.tinyClassName(this) + " eventListeners=" + Util.keys(_eventListeners) +
            ":" + Util.values(_eventListeners);
    }

    public function willTrigger (type :String) :Boolean
    {
        return hasEventListener(type);
    }

    protected var _eventListeners :Dictionary;

    protected static const log :Log = Log.getLog(EventDispatcherNonCloning);
}
}

