package com.threerings.flashbang.pushbutton.old {
public interface IEntityComponent
{
      /**
       * A reference to the entity that this component currently belongs to. If
       * the component has not been added to an entity, this will be null.
       *
       * This value should be equivelent to the first parameter passed to the Register
       * method.
       *
       * @see #Register()
       */
      function get owner():IEntity;

      /**
       * The name given to the component when it is added to an entity.
       *
       * This value should be equivelent to the second parameter passed to the Register
       * method.
       *
       * @see #Register()
       */
      function get name():String;

      /**
       * Whether or not the component is currently registered with an entity.
       */
      function get isRegistered():Boolean;

      /**
       * Registers the component with an entity. This should only ever be called by
       * an entity class from the AddComponent method.
       *
       * @param owner The entity to register the component with.
       * @param name The name to assign to the component.
       */
      function register(owner:IEntity):void;

      /**
       * Unregisters the component from an entity. This should only ever be called by
       * an entity class from the RemoveComponent method.
       */
      function unregister():void;

      /**
       * This is called by an entity on all of its components any time a component
       * is added or removed. In this method, any references to properties on the
       * owner entity should be purged and re-looked up.
       */
      function reset():void;
}
}