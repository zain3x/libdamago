package com.threerings.flashbang.pbe {
import com.pblabs.engine.core.PBGroup;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import flash.events.IEventDispatcher;
import flash.utils.getTimer;
import com.threerings.flashbang.pushbutton.EntityRef;
import com.threerings.util.ClassUtil;
import com.threerings.util.DebugUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import net.amago.util.EventDispatcherNonCloning;
public class EntityObject implements IEntity
{
    public static const GROUP_ENTITY :String = "EntityGroup";

    public var stringFunc :Function;

    public function EntityObject (name :String = null)
    {
        _name = name;
    }

    public function get alias () :String
    {
        return null;
    }

    public function get db () :ObjectDBPBE
    {
        return _parentDB;
    }

    public function get deferring () :Boolean
    {
        return _deferring;
    }

    public function set deferring (value :Boolean) :void
    {
        var before :int;
        var after :int;
        if (_deferring == true && value == false) {
            // Resolve everything, and everything that that resolution triggers.
            var needReset :Boolean = _deferredComponents.length > 0;
            while (_deferredComponents.length) {
                var pc :PendingComponent = _deferredComponents.shift() as PendingComponent;
                before = getTimer();
                pc.item.register(this, pc.name);
                after = getTimer();
            }

            // Mark deferring as done.
            _deferring = false;

            // Fire off the reset.
            if (needReset)
                doResetComponents();
        }

        _deferring = value;
    }

    public function get eventDispatcher () :IEventDispatcher
    {
        return _dispatcher;
    }

    public function set eventDispatcher (val :IEventDispatcher) :void
    {
        _dispatcher = val;
    }

    public function get globalDispatcher () :IEventDispatcher
    {
        return db;
    }
    
    /**
     * Returns true if the object is in an ObjectDB and is "live"
     * (not pending removal from the database)
     */
    public function get isLiveObject () :Boolean
    {
        return (null != _ref && !_ref.isNull);
    }

    public function get name () :String
    {
        return objectName
    }

    override public function get objectName () :String
    {
        return _name;
    }

    public function get owningGroup () :PBGroup
    {
        throw new Error(ClassUtil.tinyClassName(GameObjectEntity) +
            ".get owningGroup: Not implemented");
    }

    public function set owningGroup (value :PBGroup) :void
    {
        throw new Error(ClassUtil.tinyClassName(GameObjectEntity) +
            ".set owningGroup: Not implemented");
    }

    public function addComponent (component :IEntityComponent, componentName :String) :Boolean
    {
        if (componentName == null) {
            throw new Error("componentName cannot be null");
        }

        if (lookupComponentByName(componentName) != null) {
            throw new Error("component already exists with name " + componentName + ":" +
                lookupComponentByName(componentName));
        }

        if (_componentMap.containsKey(componentName)) {
            return false;
        }

        _componentMap.put(componentName, component);
        _components.push(component);

        if (isLiveObject && !deferring) {
            component.register(this, componentName);
            doResetComponents();
        } else {
            var p :PendingComponent = new PendingComponent();
            p.item = component;
            p.name = componentName;
            _deferredComponents.push(p);
            deferring = true;
        }

        return true;
    }

    public function deserialize (xml :XML, registerComponents :Boolean = true) :void
    {
        throw new Error("Not implemented");
    }

    public function destroy () :void
    {
        if (isLiveObject) {
            db.destroyEntity(_ref);
        }
    }
    
    public function doesPropertyExist (property :PropertyReference) :Boolean
    {
        return findProperty(db, this, property, false, _tempPropertyInfo, true) != null;
    }

    public function getProperty (property :PropertyReference, defaultVal :* = null) :*
    {
        // Look up the property.
        var info :PropertyInfo = ObjectDBPBE.findProperty(db, this, property, false, _tempPropertyInfo, true);
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

    public function hasComponent (componentType :Class) :Boolean
    {
        return null != lookupComponentByType(componentType);
    }

    public function initialize (name :String = null, alias :String = null) :void
    {
        //Not implemented
    }

    public function lookupComponentByName (componentName :String) :IEntityComponent
    {
        return _componentMap.get(componentName) as IEntityComponent;
    }

    public function lookupComponentByType (componentType :Class) :IEntityComponent
    {
        for each (var c :IEntityComponent in _components) {
            if (c is componentType) {
                return c;
            }
        }
        return null;
    }

    public function lookupComponentsByType (componentType :Class) :Array
    {
        var comps :Array = [];
        for each (var c :IEntityComponent in _components) {
            if (c is componentType) {
                comps.push(c);
            }
        }
        return comps;
    }

    public function removeComponent (component :IEntityComponent) :void
    {
        throw new Error("removeComponent not implemented.  Components are removed all at once" +
            "when the Entity is destroyed");
    }

    public function serialize (xml :XML) :void
    {
        log.warning("serialize() not implemented");
    }

    public function setProperty (property :PropertyReference, value :*) :void
    {
        // Look up and set.
        var info :PropertyInfo = findProperty(db, this, property, true, _tempPropertyInfo);
        if (info != null) {
            info.setValue(value);
        } else {
            log.warning("setProperty", "property", property, "info", info);
        }

        // Clean up to avoid dangling references.
        _tempPropertyInfo.clear();
    }

    protected function doRegisterComponents () :void
    {
        for each (var componentName :String in _componentMap.keys()) {
            var component :IEntityComponent = _componentMap.get(componentName) as IEntityComponent;
            // Skip ones we have already registered.
            if (component.isRegistered) {
                continue;
            }
            component.register(this, componentName);
        }
        doResetComponents();
    }

    protected function doResetComponents () :void
    {
        for each (var component :IEntityComponent in _components) {
            component.reset();
        }
    }
    
    internal function addDependentToDB (obj :IEntity, isSceneObject :Boolean,
                                        displayParent :DisplayObjectContainer, displayIdx :int) :void
    {
        var ref :EntityRef;
        if (isSceneObject) {
//            if (!(_parentDB is AppMode)) {
//                throw new Error("can't add SceneObject to non-AppMode ObjectDB");
//            }
//            ref = AppMode(_parentDB).addSceneObject(obj, displayParent, displayIdx);
            throw new Error("Not implemented");
        } else {
            ref = _parentDB.addEntity(obj);
        }
        _dependentObjectRefs.push(ref);
    }
    
    
    
    internal function addedToDBInternal () :void
    {
        for each (var dep :PendingDependentEntity in _pendingDependentObjects) {
            addDependentToDB(dep.obj, dep.isSceneObject, dep.displayParent, dep.displayIdx);
        }
        _pendingDependentObjects = null;
        addedToDB();
    }
    
    internal function destroyedInternal () :void
    {
        destroyed();
        _events.freeAllHandlers();
        
        //Destroy all components
        for each (var c :IEntityComponent in _components) {
            c.unregister();
        }
        _components = null;
        _componentMap.clear();
    }
    
    internal function removedFromDBInternal () :void
    {
        for each (var ref :EntityRef in _dependentObjectRefs) {
            if (ref.isLive) {
                ref.object.destroy();
            }
        }
        removedFromDB();
    }

    protected var _componentMap :Map = Maps.newMapOf(String);
    protected var _deferredComponents :Array = new Array();
    protected var _deferring :Boolean = true;
    
    protected var _dependentObjectRefs :Array = [];
    protected var _dispatcher :IEventDispatcher = new EventDispatcherNonCloning();

    protected var _name :String = null;
    protected var _pendingDependentObjects :Array = [];
    protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

    internal var _components :Array = [];
    internal var _parentDB :ObjectDBPBE;
    
    // managed by ObjectDB/AppMode
    internal var _ref :EntityRef;

    protected static const log :Log = Log.getLog(GameObjectEntity);

    internal static function handleMissingProperty (suppressErrors :Boolean,
        reference :PropertyReference, context :Object, msg :String = null) :void
    {
        if (suppressErrors) {
            return;
        }
        if (msg == null) {
            msg = "findProperty couldn't resolve";
        }
        log.warning(msg, "context", context, "ref", reference.property);
        trace(DebugUtil.getStackTrace());
    }
}
}

import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import flash.display.DisplayObjectContainer;
import com.threerings.flashbang.GameObject;
final class PendingComponent
{
    public var item :IEntityComponent;
    public var name :String;
}





class PendingDependentEntity
{
    public var displayIdx :int;
    public var displayParent :DisplayObjectContainer;
    public var isSceneObject :Boolean;
    public var obj :IEntity;
    
    public function PendingDependentEntity (obj :IEntity, isSceneObject :Boolean,
                                            displayParent :DisplayObjectContainer, displayIdx :int)
    {
        this.obj = obj;
        this.isSceneObject = isSceneObject;
        this.displayParent = displayParent;
        this.displayIdx = displayIdx;
    }
}
