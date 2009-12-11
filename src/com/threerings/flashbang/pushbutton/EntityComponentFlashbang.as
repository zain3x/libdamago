package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.util.EventHandlerManager;

import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
public class EntityComponentFlashbang extends EntityComponent
{
    override protected function onRemove():void
    {
        super.onRemove();
        _events.freeAllHandlers();
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the EntityComponent is
     * removed.
     */
    protected function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     *
     * Listeners registered in this way will be automatically unregistered when the EntityComponent is
     * removed.
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

    protected function get globalDispatcher () :EventDispatcher
    {
        if (owner == null || !(owner is GameObjectEntity)) {
            return null;
        }
        return GameObjectEntity(owner).db as EventDispatcher;
    }

    protected function get db () :EntityAppmode
    {
        if (owner == null || !(owner is GameObjectEntity)) {
            return null;
        }
        return GameObjectEntity(owner).db as EntityAppmode;
    }

    protected function getComponentByName (componentName :String) :IEntityComponent
    {
        return db.getComponent(componentName);
    }

    protected function getComponentsNamed (componentName :String) :Array
    {
        return db.getComponents(componentName);
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
}
}