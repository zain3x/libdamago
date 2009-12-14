package com.threerings.flashbang.pushbutton {

import com.pblabs.engine.entity.IEntity;
import com.threerings.flashbang.ObjectTask;

import flash.events.IEventDispatcher;

public interface IEntityExtended extends IEntity, Tasker
{
    /**
     * The event dispatcher that controls events for this entity. Components should
     * use this to dispatch and listen for events.
     */
    function get dispatcher () :IEventDispatcher;

    function get globalDispatcher () :IEventDispatcher;

    function getEntity (entityName :String) :IEntityExtended;

    function getEntitiesInGroup (groupName :String) :Array;//<GameObjectRef>


}
}