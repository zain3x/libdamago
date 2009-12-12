package com.threerings.flashbang.pushbutton {
public interface IEntityManager
{
    function getEntity (predicate :Function) :IEntity;
    function getEntities (predicate :Function = null) :Array;
    function getComponent (predicate :Function) :IEntityComponent;
    function getComponents (predicate :Function = null) :Array;
}
}