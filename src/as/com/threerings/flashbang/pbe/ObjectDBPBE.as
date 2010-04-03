package com.threerings.flashbang.pbe {
import com.pblabs.engine.core.ITickedObject;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.ObjectDB;
import com.threerings.flashbang.pushbutton.EntityRef;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;


/**
 * Manages EntityObjects objects.
 * 
 * There is a bunch of duplicated functionality with ObjectDB but for entityies because 
 * EntityObjects have some specific functionality that could not be accomplished by the 
 * EntityObjects themselves simply extending GameObject.
 * 
 * 1) EntityObjects do not need to be updated.  Only relevant components do, so it can be 
 * inefficient to be needlessly updating large number of objects.
 * 2) EntityObjects need to have the components init'd before calling addedToDB(), but the 
 * components needed the _parentDB field set to properly init. This was achieved via extending 
 * addedToDB() but could be broken on sublclasses.
 * 
 * @author dion
 */
public class ObjectDBPBE extends ObjectDB
{
    public static const OBJECT_ADDED :String = "objectAdded";
    public static const OBJECT_REMOVED :String = "objectRemoved";

    /**
     * Adds a GameObject to the ObjectDB. The GameObject must not be owned by another ObjectDB.
     */
    public function addEntity (obj :EntityObject) :EntityRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to " +
                "another ObjectDB");
        }

        // create a new PBEObjectRef
        var ref :EntityRef = new EntityRef();
        ref._obj = obj;

        // add the ref to the list
        var oldListHead :EntityRef = _entityListHead;
        _entityListHead = ref;

        if (null != oldListHead) {
            ref._next = oldListHead;
            oldListHead._prev = ref;
        }

        // initialize object
        obj._parentDB = this;
        obj._ref = ref;

        // does the object have a name?
        var objectName :String = obj.name;
        if (null != objectName) {
            var oldObj :* = _namedEntities.put(objectName, obj);
            if (undefined !== oldObj) {
                throw new Error("two objects with the same name ('" + objectName + "') " +
                    "added to the ObjectDB");
            }
        }

        addTickedComponents(obj);
        
        obj.addedToDBInternal();

        ++_objectCount;
        

        return ref;
    }

    /** Removes a GameObject from the ObjectDB. */
    public function destroyEntity (ref :EntityRef) :void
    {
        if (null == ref) {
            return;
        }

        var obj :EntityObject = ref.object;

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

        if (null == _entitiesPendingRemoval) {
            _entitiesPendingRemoval = new Array();
        }

        // the ref will be unlinked from the objects list
        // at the end of the update()
        _entitiesPendingRemoval.push(obj);

        --_objectCount;
    }

    /** Returns the object in this mode with the given name, or null if no such object exists. */
    public function getEntityNamed (name :String) :EntityObject
    {
        return (_namedEntities.get(name) as EntityObject);
    }

    public function getProperty (property :PropertyReference, defaultVal :* = null) :*
    {
        // Look up the property.
        var info :PropertyInfo = findProperty(this, null, property, false, _tempPropertyInfo);
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

    public function getSingletonComponent (name :String) :IEntityComponent
    {
        var entity :IEntity = getEntityNamed(name) as IEntity;
        if (entity == null) {
            return null;
        }
        return entity.lookupComponentByName(name);
    }

    /** Called once per update tick. Updates all objects in the mode. */
    override public function update (dt :Number) :void
    {
        super.update(dt);
    }
    
    /** Removes dead objects from the object list at the end of an update. */
    override protected function endUpdate (dt :Number) :void
    {
        super.endUpdate(dt);
        // clean out all objects that were destroyed during the update loop
        
        if (null != _entitiesPendingRemoval) {
            for each (var obj :EntityObject in _entitiesPendingRemoval) {
                finalizeEntityRemoval(obj);
            }
            
            _entitiesPendingRemoval = null;
        }
    }

    override protected function shutdown () :void
    {
        super.shutdown();

        var ref :EntityRef = _entityListHead;
        while (null != ref) {
            if (!ref.isNull) {
                ref.object.destroyedInternal();
            }
            ref = ref._next;
        }

        _entityListHead = null;
        _entitiesPendingRemoval = null;
        _namedEntities.clear();

        _entityTickedComponentRefs.clear();
        _tickedComponentListHead = null;
        
    }

    protected function addTickedComponents (obj :EntityObject) :void
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
    
    /** Removes a single dead object from the object list. */
    protected function finalizeEntityRemoval (obj :EntityObject) :void
    {
        Assert.isTrue(null != obj._ref && null == obj._ref._obj);
        
        // unlink the object ref
        var ref :GameObjectRef = obj._ref;
        
        var prev :GameObjectRef = ref._prev;
        var next :GameObjectRef = ref._next;
        
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

    protected var _allObjects :Array = [];

    /** Elapsed time for this ObjectDB */
    protected var _elapsedTime :Number = 0;
    protected var _entitiesPendingRemoval :Array = [];

    protected var _entityListHead :EntityRef;
    protected var _entityTickedComponentRefs :Map = Maps.newMapOf(IEntity); //<IEntity, Array>
    protected var _namedEntities :Map = Maps.newMapOf(IEntity);

    protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();
    protected var _tickedComponentListHead :TickedObjectRef;

    protected static const log :Log = Log.getLog(ObjectDBPBE);

    internal static function findProperty (db :ObjectDBPBE, entity :IEntity,
        reference :PropertyReference, willSet :Boolean = false, providedPi :PropertyInfo = null,
        suppressErrors :Boolean = false) :PropertyInfo
    {
        // Early out if we got a null property reference.
        if (!reference || reference.property == null || reference.property == "") {
            return null;
        }

        // Must have a propertyInfo to operate with.
        if (!providedPi) {
            providedPi = new PropertyInfo();
        }

        // Cached lookups apply only to components.
        if (reference.cachedLookup && reference.cachedLookup.length > 0) {
            var cl :Array = reference.cachedLookup;
            var cachedWalk :* = entity.lookupComponentByName(cl[0]);
            if (!cachedWalk) {
                handleMissingProperty(suppressErrors, reference, cl[0]);
                return null;
            }

            for (var i :int = 1; i < cl.length - 1; i++) {

                if (cachedWalk is IEntity) {
                    cachedWalk = IEntity(cachedWalk).lookupComponentByName(cl[i]);
                } else {
                    cachedWalk = cachedWalk[cl[i]];
                }

                if (cachedWalk == null) {
                    handleMissingProperty(suppressErrors, reference, cl[i]);
                    return null;
                }
            }

            var cachedPi :PropertyInfo = providedPi;
            cachedPi.propertyParent = cachedWalk;
            cachedPi.propertyName = (cl.length > 1) ? cl[cl.length - 1] : null;
            //				Profiler.exit("Entity.findProperty " + reference.property);
            //            Profiler.exit("Entity.findProperty");
            return cachedPi;
        }

        // Split up the property reference.
        var propertyName :String = reference.property;
        var path :Array = propertyName.split(".");

        // Distinguish if it is a component reference (@), named object ref (#), or
        // an XML reference (!), and look up the first element in the path.
        var isTemplateXML :Boolean = false;
        var itemName :String = path[0];
        var curIdx :int = 1;
        var startChar :String = itemName.charAt(0);
        var curLookup :String = itemName.slice(1);
        var parentElem :*;
        if (startChar == "@") {
            // Component reference, look up the component by name.
            parentElem = entity.lookupComponentByName(curLookup);
            if (!parentElem) {
                handleMissingProperty(suppressErrors, reference, curLookup);
                return null;
            }

            // Cache the split out string.
            path[0] = curLookup;
            reference.cachedLookup = path;
        } else if (startChar == "#") {
            // Named object reference. Look up the entity in the NameManager.
            //            parentElem = NameManager.instance.lookup(curLookup);
            parentElem = db.getEntityNamed(curLookup);
            if (!parentElem) {
                handleMissingProperty(suppressErrors, reference, curLookup);
                return null;
            }

            // Get the component on it.
            curIdx++;
            curLookup = path[1];
            var comLookup :IEntityComponent =
                (parentElem as IEntity).lookupComponentByName(curLookup);
            if (!comLookup) {
                handleMissingProperty(suppressErrors, reference, curLookup,
                    "Could not find component on named entity '" + (parentElem as IEntity).name +
                    "'");
                return null;
            }
            parentElem = comLookup;
        } else if (startChar == "!") {
            // XML reference. Look it up inside the TemplateManager. We only support
            // templates and entities - no groups.
            //            parentElem = TemplateManager.instance.getXML(curLookup, "template", "entity");
            if (!parentElem) {
                handleMissingProperty(suppressErrors, reference, curLookup,
                    "Could not find XML name");
                return null;
            }

            // Try to find the specified component.
            curIdx++;
            var nextElem :* = null;
            for each (var cTag :*in parentElem.*) {
                if (cTag.@name == path[1]) {
                    nextElem = cTag;
                    break;
                }
            }

            // Create it if appropriate.
            if (!nextElem && willSet) {
                // Create component tag.
                (parentElem as XML).appendChild(<component name={path[1]}/>);

                // Look it up again.
                for each (cTag in parentElem.*) {
                    if (cTag.@name == path[1]) {
                        nextElem = cTag;
                        break;
                    }
                }
            }

            // Error if we don't have it!
            if (!nextElem) {
                handleMissingProperty(suppressErrors, reference, null,
                    "Could not find component '" + path[1] + "' in XML template '" + path[0].
                    slice(1) + "' for property '" + reference.property + "'");
                return null;
            }

            // Get ready to search the rest.
            parentElem = nextElem;

            // Indicate we are dealing with xml.
            isTemplateXML = true;
        } else {
            handleMissingProperty(suppressErrors, reference, startChar,
                "Got a property path that doesn't start with !, #, or @");
            return null;
        }

        // Make sure we have a field to look up.
        if (curIdx < path.length)
            curLookup = path[curIdx++] as String;
        else
            curLookup = null;

        // Do the remainder of the look up.
        while (curIdx < path.length && parentElem) {
            // Try the next element in the path.
            var oldParentElem :* = parentElem;
            try {
                if (parentElem is XML || parentElem is XMLList) {
                    parentElem = parentElem.child(curLookup);
                } else {
                    if (parentElem is IEntity) {
                        parentElem = IEntity(parentElem).lookupComponentByName(curLookup);
                    } else {
                        parentElem = parentElem[curLookup];
                    }
                }
            } catch (e :Error) {
                parentElem = null;
            }

            // Several different possibilities that indicate we failed to advance.
            var gotEmpty :Boolean = false;
            if (parentElem == undefined)
                gotEmpty = true;
            if (parentElem == null)
                gotEmpty = true;
            if (parentElem is XMLList && parentElem.length() == 0)
                gotEmpty = true;

            // If we're going to set and it's XML, create the field.
            if (willSet && isTemplateXML && gotEmpty && oldParentElem) {
                oldParentElem.appendChild(<{curLookup}/>);
                parentElem = oldParentElem.child(curLookup);
                gotEmpty = false;
            }

            if (gotEmpty) {
                handleMissingProperty(suppressErrors, reference, curLookup);
                return null;
            }

            // Advance to next element in the path.
            curLookup = path[curIdx++] as String;
        }

        // Did we end up with a match?
        if (parentElem) {
            var pi :PropertyInfo = providedPi;
            pi.propertyParent = parentElem;
            pi.propertyName = curLookup;
            //				Profiler.exit("Entity.findProperty " + reference.property);
            //            Profiler.exit("Entity.findProperty");
            return pi;
        }
        //			Profiler.exit("Entity.findProperty " + reference.property);
        //        Profiler.exit("Entity.findProperty");
        return null;
    }
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