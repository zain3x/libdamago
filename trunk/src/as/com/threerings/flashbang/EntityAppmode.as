package com.threerings.flashbang {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.pushbutton.IGroupObject;
import com.threerings.flashbang.pushbutton.PropertyInfo;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
public class EntityAppmode extends AppMode
{
    public static const OBJECT_ADDED :String = "objectAdded";
    public static const OBJECT_REMOVED :String = "objectRemoved";

    public function EntityAppmode ()
    {
        super();
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

    public function addSingletonComponent (comp :IEntityComponent, compName :String) :IEntity
    {
        log.info("addSingletonComponent", "comp", comp);
        //Profiler.enter(compName);
        var obj :GameObjectEntity = new GameObjectEntity(compName);
        obj.addComponent(comp, compName);
        addObject(obj);
        //Profiler.exit(compName);
        return obj;
    }

    public function allocateEntity () :GameObjectEntity
    {
        return new GameObjectEntity();
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

    override public function addObject (obj :GameObject) :GameObjectRef
    {
        if (null == obj || null != obj._ref) {
            throw new ArgumentError("obj must be non-null, and must never have belonged to " +
                "another ObjectDB");
        }

        // create a new GameObjectRef
        var ref :GameObjectRef = new GameObjectRef();
        ref._obj = obj;

        // add the ref to the list
        var oldListHead :GameObjectRef = _listHead;
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
        var groupName :String;
        var groupArray :Array;
        do {
            groupName = obj.getObjectGroup(groupNum++);
            if (null != groupName) {
                groupArray = (_groupedObjects.get(groupName) as Array);
                if (null == groupArray) {
                    groupArray = [];
                    _groupedObjects.put(groupName, groupArray);
                }

                groupArray.push(ref);
            }
        } while (null != groupName);

        //And the component groups
        if (obj is GameObjectEntity) {
            for each (var comp :IEntityComponent in GameObjectEntity(obj)._components) {
                if (comp is IGroupObject) {
                    for each (groupName in IGroupObject(comp).groupNames) {
                        groupArray = (_groupedObjects.get(groupName) as Array);
                        if (null == groupArray) {
                            groupArray = [];
                            _groupedObjects.put(groupName, groupArray);
                        }
                        groupArray.push(ref);
                    }
                }
            }
        }

        obj.addedToDBInternal();

        ++_objectCount;

        return ref;
    }

    override public function update (dt :Number) :void
    {
        _elapsedTime += dt;
        super.update(dt);
    }

    /**
     * Remove the component groups.
     * @param obj
     * @throws Error
     * @throws Error
     */
    override protected function finalizeObjectRemoval (obj :GameObject) :void
    {
        if (obj is GameObjectEntity) {
            var ref :GameObjectRef = obj._ref;
            for each (var comp :IEntityComponent in GameObjectEntity(obj)._components) {
                if (comp is IGroupObject) {
                    for each (var groupName :String in IGroupObject(comp).groupNames) {
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
                }
            }
        }

        super.finalizeObjectRemoval(obj);
    }

    /** Elapsed time for this ObjectDB */
    protected var _elapsedTime :Number = 0;
    protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

    protected static const log :Log = Log.getLog(EntityAppmode);
}
}