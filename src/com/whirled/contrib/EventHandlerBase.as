package com.whirled.contrib
{
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import com.threerings.util.EventHandlerManager;

public class EventHandlerBase extends EventDispatcher
{
    public function EventHandlerBase(target:IEventDispatcher=null)
    {
        super(target);
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
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _events.unregisterListener(dispatcher, event, listener, useCapture);
    }

    public function shutdown() :void
    {
        _events.freeAllHandlers();
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();


}
}
