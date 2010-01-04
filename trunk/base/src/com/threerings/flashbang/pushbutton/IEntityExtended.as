package com.threerings.flashbang.pushbutton {

import com.pblabs.engine.entity.IEntity;

import flash.events.IEventDispatcher;

public interface IEntityExtended extends IEntity, Tasker
{
    function get globalDispatcher () :IEventDispatcher;

    function getEntity (entityName :String) :IEntityExtended;

    function getEntitiesInGroup (groupName :String) :Array;//<GameObjectRef>


}
}