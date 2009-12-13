package com.threerings.flashbang.pushbutton.old {

import flash.events.IEventDispatcher;

public interface IEntity
{

    function get objectName () :String;

    /**
     * Destroys the entity by removing all components and unregistering it from
     * the name manager.
     *
     * <p>Currently this will not invalidate external references to the entity
     * so the entity will only be cleaned up by the garbage collector if those
     * are set to null manually.</p>
     */
    function destroySelf () :void;

    /**
     * Gets a component of a specific type from this entity. If more than one
     * component of a specific type exists, there is no guarantee which one
     * will be returned. To retrieve all components of a specified type, use
     * lookupComponentsByType.
     *
     * @param componentType The type of the component to retrieve.
     *
     * @return The component, or null if none of the specified type were found.
     *
     * @see #lookupComponentsByType()
     */
    function lookupComponentByType (componentType :Class) :IEntityComponent;

    /**
     * Gets a list of all the components of a specific type that are on this
     * entity.
     *
     * @param componentType The type of components to retrieve.
     *
     * @return An array containing all the components of the specified type on
     * this entity.
     */
    function lookupComponentsByType (componentType :Class) :Array;

    /**
     * Gets a component that was registered with a specific name on this entity.
     *
     * @param componentName The name of the component to retrieve. This corresponds
     * to the second parameter passed to AddComponent.
     *
     * @return The component with the specified name.
     *
     * @see #AddComponent()
     */
    function lookupComponentByName (componentName :String) :IEntityComponent;

    /**
     * The event dispatcher that controls events for this entity. Components should
     * use this to dispatch and listen for events.
     */
    function get dispatcher () :IEventDispatcher;

    /**
     * Checks whether a property exists on this entity.
     *
     * @param property The property reference describing the property to look for on
     * this entity.
     *
     * @return True if the property exists, false otherwise.
     */
    function doesPropertyExist (property :PropertyReference) :Boolean;

    /**
     * Gets the value of a property on this entity.
     *
     * @param property The property reference describing the property to look for on
     * this entity.
     * @param defaultValue If the property is not found, return this value.
     *
     * @return The current value of the property, or null if it doesn't exist.
     */
    function getProperty (property :PropertyReference, defaultValue :* = null) :*;

    /**
     * Sets the value of a property on this entity.
     *
     * @param property The property reference describing the property to look for on
     * this entity.
     *
     * @param value The value to set on the specified property.
     */
    function setProperty (property :PropertyReference, value :*) :void;

    function get globalDispatcher () :IEventDispatcher;

//    function get manager () :IEntityManager;

    function getEntity (entityName :String) :IEntity;
    function getEntitiesInGroup (groupName :String) :Array;//<GameObjectRef>


//    function getEntity (predicate :Function) :IEntity;
//    function getComponent (predicate :Function) :IEntityComponent;
//    function getEntities (predicate :Function = null) :Array;
}
}