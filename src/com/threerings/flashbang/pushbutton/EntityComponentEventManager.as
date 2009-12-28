package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.threerings.util.EventHandlerManager;

import flash.events.IEventDispatcher;

/**
 * An implementation of the IEntityComponent interface, providing all the basic
 * functionality required of all components. Custom components should always
 * derive from this class rather than implementing IEntityComponent directly.
 *
 * @see IEntity
 * @see ../../../../../Examples/CreatingComponents.html Creating Custom Components
 * @see ../../../../../Reference/ComponentSystem.html Component System Overview
 */
public class EntityComponentEventManager implements IEntityComponent
{

    public function EntityComponentEventManager (name :String = null)
    {
        _name = name;
    }
    /**
     * @inheritDoc
     */
    public function get isRegistered () :Boolean
    {
        return _owner != null;
    }

    /**
     * @inheritDoc
     */
    public function get name () :String
    {
        return _name;
//        throw new Error("Abstract method on " + this);
    }

    public function set name (val :String) :void
    {
        if (isRegistered) {
            throw new Error("Cannot set name for a registed component, this will break the " +
                    "Entity groups.");
        }
        _name = val;
    }

    /**
     * @inheritDoc
     */
    public function get owner () :IEntity
    {
        return _owner;
    }

    /**
     * @inheritDoc
     */
    public function register (owner :IEntity, name:String) :void
    {
        if (isRegistered) {
            throw new Error("Trying to register an already-registered component!");
		}
        _owner = owner;
		_name = name;
        onAdd();
    }

    /**
     * @inheritDoc
     */
    public function reset () :void
    {
        onReset();
    }

    /**
     * @inheritDoc
     */
    public function unregister () :void
    {
        if (!isRegistered)
            throw new Error("Trying to unregister an unregistered component!");

        onRemove();
        _owner = null;
    }

    /**
     * This is called when the component is added to an entity. Any initialization,
     * event registration, or object lookups should happen here. Component lookups
     * on the owner entity should NOT happen here. Use onReset instead.
     *
     * @see #onReset()
     */
    protected function onAdd () :void
    {
    }

    /**
     * This is called anytime a component is added or removed from the owner entity.
     * Lookups of other components on the owner entity should happen here.
     *
     * <p>This can potentially be called multiple times, so make sure previous lookups
     * are properly cleaned up each time.</p>
     */
    protected function onReset () :void
    {
		_events.freeAllHandlers();
    }

    /**
     * This is called when the component is removed from an entity. It should reverse
     * anything that happened in onAdd or onReset (like removing event listeners or
     * nulling object references).
     */
    protected function onRemove():void
    {
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

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _owner :IEntity = null;
    protected var _name :String = null;
}
}