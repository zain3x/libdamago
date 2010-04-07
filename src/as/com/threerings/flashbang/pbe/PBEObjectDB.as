package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.core.ITickedObject;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import com.threerings.flashbang.Updatable;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Assert;
import com.threerings.util.EventHandlerManager;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.flashbang.GameObjectEntity;

public class PBEObjectDB extends EventDispatcher implements Updatable
{
    public static const OBJECT_ADDED :String = "objectAdded";
    public static const OBJECT_REMOVED :String = "objectRemoved";

    public function get allObjects () :Array //<PBEObject
    {
        return _allObjects.map(function (ref :EntityRef, ... _) :PBEObject {
                return ref.object;
            });
    }

    public function get elapsedTime () :Number
    {
        return _elapsedTime;
    }

    public function get groupNames () :Array
    {
        return _groupedObjects.keys();
    }

    public function get namedObjects () :Array
    {
        return _namedObjects.values();
    }

    /** Returns the number of live GameObjects in this ObjectDB. */
    public function get objectCount () :uint
    {
        return _objectCount;
    }

    /**
     * Adds a GameObject to the ObjectDB. The GameObject must not be owned by another ObjectDB.
     */
    public function addObject (obj :PBEObject) :EntityRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to " +
                "another ObjectDB");
        }

        // create a new PBEObjectRef
        var ref :EntityRef = new EntityRef();
        ref._obj = obj;

        // add the ref to the list
        var oldListHead :EntityRef = _listHead;
        _listHead = ref;

        if (null != oldListHead) {
            ref._next = oldListHead;
            oldListHead._prev = ref;
        }

        // initialize object
        obj._parentDB = this;
        obj._ref = ref;

        // does the object have a name?
        var objectName :String = obj.objectName;
        if (null != objectName) {
            var oldObj :* = _namedObjects.put(objectName, obj);
            if (undefined !== oldObj) {
                throw new Error("two objects with the same name ('" + objectName + "') " +
                    "added to the ObjectDB");
            }
        }

        // iterate over the object's groups
        var groupNum :int = 0;
        do {
            var groupName :String = obj.getObjectGroup(groupNum++);
            if (null != groupName) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    groupArray = [];
                    _groupedObjects.put(groupName, groupArray);
                }

                groupArray.push(ref);
            }
        } while (null != groupName);

        obj.addedToDBInternal();

        ++_objectCount;

        return ref;
    }

    public function addSingletonComponent (comp :IEntityComponent, compName :String) :IEntity
    {
        log.info("addSingletonComponent", "comp", comp);
        //		Profiler.enter(compName);
        var obj :GameObjectEntity = new GameObjectEntity(compName);
        obj.addComponent(comp, compName);
        addObject(obj);
        //		Profiler.exit(compName);
        return obj;
    }

    /** Removes a GameObject from the ObjectDB. */
    public function destroyObject (ref :EntityRef) :void
    {
        if (null == ref) {
            return;
        }

        var obj :PBEObject = ref.object;

        if (null == obj) {
            return;
        }

        // the ref no longer points to the object
        ref._obj = null;

        // does the object have a name?
        var objectName :String = obj.objectName;
        if (null != objectName) {
            _namedObjects.remove(objectName);
        }

        obj.removedFromDBInternal();
        obj.destroyedInternal();

        if (null == _objectsPendingRemoval) {
            _objectsPendingRemoval = new Array();
        }

        // the ref will be unlinked from the objects list
        // at the end of the update()
        _objectsPendingRemoval.push(obj);

        --_objectCount;
    }

    /** Removes a GameObject from the ObjectDB. */
    public function destroyObjectNamed (name :String) :void
    {
        var obj :PBEObject = getObjectNamed(name);
        if (null != obj) {
            destroyObject(obj.ref);
        }
    }

    /** Removes all GameObjects in the given group from the ObjectDB. */
    public function destroyObjectsInGroup (groupName :String) :void
    {
        for each (var ref :EntityRef in getObjectRefsInGroup(groupName)) {
            if (!ref.isNull) {
                ref.object.destroySelf();
            }
        }
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getObjectNamed (name :String) :PBEObject
    {
        return (_namedObjects.get(name) as PBEObject);
    }

    /**
     * Returns an Array containing the object refs of all the objects in the given group.
     * This Array must not be modified by client code.
     *
     * Note: the returned Array will contain null object refs for objects that were destroyed
     * this frame and haven't yet been cleaned up.
     */
    public function getObjectRefsInGroup (groupName :String) :Array
    {
        var refs :Array = (_groupedObjects.get(groupName) as Array);

        return (null != refs ? refs : []);
    }

    /**
     * Returns an Array containing the GameObjects in the given group.
     * The returned Array is instantiated by the function, and so can be
     * safely modified by client code.
     *
     * This function is not as performant as getObjectRefsInGroup().
     */
    public function getObjectsInGroup (groupName :String) :Array
    {
        var refs :Array = getObjectRefsInGroup(groupName);

        // Array.map would be appropriate here, except that the resultant
        // Array might contain fewer entries than the source.

        var objs :Array = new Array();
        for each (var ref :EntityRef in refs) {
            if (!ref.isNull) {
                objs.push(ref.object);
            }
        }

        return objs;
    }

    public function getProperty (property :PropertyReference, defaultVal :* = null) :*
    {
        // Look up the property.
        var info :PropertyInfo = GameObjectEntity.findProperty(this, null, property, false,
            _tempPropertyInfo);
        var result :* = null;

        // Get value if any.
        if (info)
            result = info.getValue();
        else
            result = defaultVal;

        // Clean up to avoid dangling references.
        _tempPropertyInfo.clear();

        return result;
    }

    public function getPropertyFromPropString (propertyString :String, defaultVal :* = null) :*
    {
        return getProperty(new PropertyReference(propertyString), defaultVal);
    }

    public function getSingletonComponent (name :String) :IEntityComponent
    {
        var entity :IEntity = getObjectNamed(name) as IEntity;
        if (entity == null) {
            return null;
        }
        return entity.lookupComponentByName(name);
    }

    /** Called once per update tick. Updates all objects in the mode. */
    public function update (dt :Number) :void
    {
        beginUpdate(dt);
        endUpdate(dt);
    }

    protected function addTickedComponents (obj :GameObjectEntity) :void
    {
        var tickedComponents :Array;
        for each (var comp :IEntityComponent in obj._components) {
            if (comp is ITickedObject) {
                var ticked :ITickedObject = comp as ITickedObject;

                // create a new TickedObjectRef
                var ref :TickedObjectRef = new TickedObjectRef();
                ref._obj = ticked;

                // add the ref to the list
                var oldListHead :TickedObjectRef = _tickedListHead;
                _tickedListHead = ref;

                if (null != oldListHead) {
                    ref._next = oldListHead;
                    oldListHead._prev = ref;
                }

                //Add it to an array
                if (tickedComponents == null) {
                    tickedComponents = [ ref ];
                } else {
                    tickedComponents.push(ref);
                }
            }
        }
        if (tickedComponents != null) {
            _entityTickedComponentRefs.put(obj, tickedComponents);
        }

    }

    /** Updates all objects in the mode. */
    protected function beginUpdate (dt :Number) :void
    {
        // update all ticked components
        _elapsedTime += dt;
        updateTickedComponents(dt);
    }

    /** Removes dead objects from the object list at the end of an update. */
    protected function endUpdate (dt :Number) :void
    {
        // clean out all objects that were destroyed during the update loop

        if (null != _objectsPendingRemoval) {
            for each (var obj :PBEObject in _objectsPendingRemoval) {
                finalizeObjectRemoval(obj);
            }

            _objectsPendingRemoval = null;
        }
    }

    /** Removes a single dead object from the object list. */
    protected function finalizeObjectRemoval (obj :PBEObject) :void
    {
        Assert.isTrue(null != obj._ref && null == obj._ref._obj);

        // unlink the object ref
        var ref :EntityRef = obj._ref;

        var prev :EntityRef = ref._prev;
        var next :EntityRef = ref._next;

        if (null != prev) {
            prev._next = next;
        } else {
            // if prev is null, ref was the head of the list
            Assert.isTrue(ref == _listHead);
            _listHead = next;
        }

        if (null != next) {
            next._prev = prev;
        }

        // iterate over the object's groups
        // (we remove the object from its groups here, rather than in
        // destroyObject(), because client code might be iterating an
        // object group Array when destroyObject is called)
        var groupNum :int = 0;
        do {
            var groupName :String = obj.getObjectGroup(groupNum++);
            if (null != groupName) {
                var groupArray :Array = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    throw new Error("destroyed GameObject is returning different object groups " +
                        "than it did on creation");
                }

                var wasInArray :Boolean = ArrayUtil.removeFirst(groupArray, ref);
                if (!wasInArray) {
                    throw new Error("destroyed GameObject is returning different object groups " +
                        "than it did on creation");
                }
            }
        } while (null != groupName);

        obj._parentDB = null;
    }

    /**
     * Adds the specified listener to the specified dispatcher for the specified event.
     *
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
     */
    protected function registerListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerListener(dispatcher, event, listener, useCapture, priority);
    }

    /**
     * Registers a zero-arg callback function that should be called once when the event fires.
     *
     * Listeners registered in this way will be automatically unregistered when the ObjectDB is
     * shutdown.
     */
    protected function registerOneShotCallback (dispatcher :IEventDispatcher, event :String,
        callback :Function, useCapture :Boolean = false, priority :int = 0) :void
    {
        _events.registerOneShotCallback(dispatcher, event, callback, useCapture, priority);
    }

    protected function removeTickedComponents (obj :GameObjectEntity) :void
    {
        var refs :Array = _entityTickedComponentRefs.get(obj) as Array;
        if (refs != null) {
            for each (var ref :TickedObjectRef in refs) {
                unlinkTickedRef(ref);
            }
        }
    }

    /**
     * Destroys all GameObjects contained by this ObjectDB. Applications generally don't need
     * to call this function - it's called automatically when an {@link AppMode} is popped from
     * the mode stack.
     */
    protected function shutdown () :void
    {
        var ref :EntityRef = _listHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.destroyedInternal();
            }

            ref = ref._next;
        }

        _listHead = null;
        _objectCount = 0;
        _objectsPendingRemoval = null;
        _namedObjects = null;
        _groupedObjects = null;

        _events.freeAllHandlers();
    }

    /** Removes a single dead object from the object list. */
    protected function unlinkTickedRef (ref :TickedObjectRef) :void
    {
        // unlink the object ref
        ref._obj = null;
        var prev :TickedObjectRef = ref._prev;
        var next :TickedObjectRef = ref._next;

        if (null != prev) {
            prev._next = next;
        } else {
            // if prev is null, ref was the head of the list
            Assert.isTrue(ref == _tickedListHead);
            _tickedListHead = next;
        }

        if (null != next) {
            next._prev = prev;
        }
    }

    /**
     * Removes the specified listener from the specified dispatcher for the specified event.
     */
    protected function unregisterListener (dispatcher :IEventDispatcher, event :String,
        listener :Function, useCapture :Boolean = false) :void
    {
        _events.unregisterListener(dispatcher, event, listener, useCapture);
    }

    /** Updates all objects in the mode. */
    protected function updateTickedComponents (dt :Number) :void
    {
        // update all ITickedObjects
        var ref :TickedObjectRef = _tickedListHead;
        while (null != ref) {
            var obj :ITickedObject = ref._obj;
            if (null != obj) {
                obj.onTick(dt);
            }
            ref = ref._next;
        }
    }

    protected var _allObjects :Array = [];

    /** Elapsed time for this ObjectDB */
    protected var _elapsedTime :Number = 0;
    protected var _entityTickedComponentRefs :Map = Maps.newMapOf(IEntity); //<IEntity, Array>

    protected var _events :EventHandlerManager = new EventHandlerManager();

    /** stores a mapping from String to Array */
    protected var _groupedObjects :Map = Maps.newMapOf(String);

    protected var _listHead :EntityRef;

    /** stores a mapping from String to Object */
    protected var _namedObjects :Map = Maps.newMapOf(String);
    protected var _objectCount :uint;

    /** An array of GameObjects */
    protected var _objectsPendingRemoval :Array;
    protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();
    protected var _tickedListHead :TickedObjectRef;

    protected static const log :Log = Log.getLog(PBEObjectDB);
}

}

import com.pblabs.engine.core.ITickedObject;

class TickedObjectRef
{
    public static function Null () :TickedObjectRef
    {
        return g_null;
    }

    public function get isLive () :Boolean
    {
        return (null != _obj);
    }

    public function get isNull () :Boolean
    {
        return (null == _obj);
    }

    public function get object () :ITickedObject
    {
        return _obj;
    }

    internal var _next :TickedObjectRef;

    // managed by ObjectDB
    internal var _obj :ITickedObject;
    internal var _prev :TickedObjectRef;

    protected static var g_null :TickedObjectRef = new TickedObjectRef();
}
