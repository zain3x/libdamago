package com.threerings.flashbang {
    import flash.utils.Dictionary;
    import com.pblabs.engine.core.IAnimatedObject;
    import com.pblabs.engine.core.ITickedObject;
    import com.pblabs.engine.core.PBGroup;
    import com.pblabs.engine.entity.IEntity;
    import com.pblabs.engine.entity.IEntityComponent;
    import com.pblabs.engine.entity.PropertyReference;
    import com.threerings.flashbang.pushbutton.PropertyInfo;
    import com.threerings.pbe.tasks.TaskComponent;
    import com.threerings.util.ArrayUtil;
    import com.threerings.util.ClassUtil;
    import com.threerings.util.DebugUtil;
    import com.threerings.util.Log;
    import com.threerings.util.Predicates;
    import com.threerings.util.StringUtil;

    import flash.events.IEventDispatcher;

    import net.amago.util.EventDispatcherNonCloning;
    /**
     * A modification of GameObject.  Utilizes EntityComponents.
     * Rather that creating GameObjects with extra functionality via extending this class,
     * behaviour is built via adding IEntityComponents.
     *
     */
    public class GameObjectEntity extends GameObject implements IEntity
    {
        public static const GROUP_ENTITY :String = "EntityGroup";

        public var stringFunc :Function;

        public function GameObjectEntity (name :String = null)
        {
            _name = name;
        }

        public function get alias () :String
        {
            return null;
        }

        public function get dbComponent () :EntityAppmode
        {
            return db as EntityAppmode;
        }

        public function get components () :Array
        {
            return _components;//Don't modify
        }

        public function get deferring():Boolean
        {
            return _deferring;
        }

        public function set deferring(value:Boolean):void
        {
            if(isLiveObject && _deferring == true && value == false)
            {
                // Resolve everything, and everything that that resolution triggers.
                var needReset:Boolean = _deferredComponents.length > 0;
                while(_deferredComponents.length)
                {
                    var pc:PendingComponent = _deferredComponents.shift() as PendingComponent;
                    pc.item.register(this, pc.name);
                }

                // Mark deferring as done.
                _deferring = false;

                // Fire off the reset.
                if(needReset)
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
            throw new Error("Don't do this");
        }

        public function get globalDispatcher () :IEventDispatcher
        {
            return db;
        }

        public function get name () :String
        {
            return objectName
        }

        override public function get objectName () :String
        {
            return _name;
        }

        public function get owningGroup():PBGroup
        {
            throw new Error(ClassUtil.tinyClassName(GameObjectEntity) +
                ".get owningGroup: Not implemented");
        }

        public function set owningGroup(value:PBGroup):void
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

            if (componentName in _componentDict) {
                return false;
            }

            _componentDict[componentName] = component;
            _components.push(component);
            if (component is IAnimatedObject) {
                _animatedComponents.push(component);
            }
            if (component is ITickedObject) {
                _tickedComponents.push(component);
            }

            if (isLiveObject && !deferring) {
                component.register(this, componentName);
                doResetComponents();
            } else {
                var p:PendingComponent = new PendingComponent();
                p.item = component;
                p.name = componentName;
                _deferredComponents.push(p);
                //deferring = true;
            }

            return true;
        }

        public function deserialize (xml :XML, registerComponents :Boolean = true) :void
        {
        }

        public function destroy () :void
        {
            _destroyed = true;
            if (isLiveObject) {
                destroySelf();
            }
        }

        public function doesPropertyExist (property :PropertyReference) :Boolean
        {
            return findProperty(db, this, property, false, _tempPropertyInfo, true) != null;
        }

        public function getEntitiesInGroup (groupName :String) :Array //<IEntity>
        {
            return db.getObjectsInGroup(groupName).filter(Predicates.createIs(IEntity));
        }

        public function getEntity (entityName :String) :IEntity
        {
            return db.getObjectNamed(entityName) as IEntity;
        }

        public function getProperty (property :PropertyReference, defaultVal :* = null) :*
        {
            // Look up the property.
            var info :PropertyInfo = findProperty(db, this, property, false, _tempPropertyInfo, true);
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
            return _componentDict[componentName] as IEntityComponent;
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
            removeComponentInternal(component);
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

        override public function toString() : String
        {
            if (stringFunc == null) {
                return super.toString();
            }
            if (!isLiveObject) {
                return "Destroyed Object";
            }
            if (stringFunc != null) {
                return stringFunc(this) as String;
            } else if (ClassUtil.getClass(this) != GameObjectEntity) {
                return StringUtil.simpleToString(this);
            } else {
                return String(_components.length > 1 ? _components[1] : this);//String the first component
            }
        }

        override protected function addedToDB () :void
        {
            super.addedToDB();
            deferring = false;
        }

        override protected function update (dt :Number) :void
        {
            for each (var t :ITickedObject in _tickedComponents) {
                if (_destroyed) {//A component may trigger a destroy call.
                    break;
                }
                t.onTick(dt);
            }
            for each (var a :IAnimatedObject in _animatedComponents) {
                if (_destroyed) {//A component may trigger a destroy call.
                    break;
                }
                a.onFrame(dt);
            }
        }

        protected function doRegisterComponents () :void
        {
            for each (var componentName :String in _componentDict) {
                var component :IEntityComponent = _componentDict[componentName] as IEntityComponent;
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

        internal function destroyComponents () :void
        {
            _components = null;
            _tickedComponents = null;
            _animatedComponents = null;
            _componentDict = new Dictionary();
        }

        internal function unregisterComponents () :void
        {
            //Also remove listeners here
            _dispatcher.removeAllListeners();
            for each (var c :IEntityComponent in _components) {
                c.unregister();
            }
        }

        internal function removeComponentInternal (component :IEntityComponent,
            reset :Boolean = true) :void
        {
            if (!(component.name in _componentDict)) {
                return;
            }

            if (isLiveObject) {
                throw new Error(ClassUtil.tinyClassName(this) + " cannot handle removing " +
                    "components while still a live GameObject: it fucks with the ObjectDB groups.");
            }

            //Remove from the deferred components
            ArrayUtil.removeFirstIf(_deferredComponents,
                Predicates.createPropertyEquals("item", component));

            if (component.isRegistered) {
                component.unregister();
            }

            delete _componentDict[component.name];
            ArrayUtil.removeFirst(_components, component);
            ArrayUtil.removeFirst(_tickedComponents, component);
            ArrayUtil.removeFirst(_animatedComponents, component);
            if (reset) {
                doResetComponents();
            }

        }

        protected var _destroyed :Boolean;
        // components by name.  Use a Dictionary rather than a Map as Dictionary is 20x faster.
        protected var _componentDict :Dictionary = new Dictionary();
        protected var _deferredComponents:Array = new Array();
        protected var _deferring:Boolean = true;
        protected var _dispatcher :EventDispatcherNonCloning = new EventDispatcherNonCloning();

        protected var _name :String = null;
        protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

        // Store ticked and animated components on their own in addition to storing them in the
        // _components list to keep from needing to do instance checks on all the components on
        // every tick.
        internal var _components :Array = [];
        internal var _tickedComponents :Array = [];
        internal var _animatedComponents :Array = [];

        protected static const log :Log = Log.getLog(GameObjectEntity);

        internal static function findProperty (db :ObjectDB, entity :IEntity,
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
                parentElem = db.getObjectNamed(curLookup);
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
                        "Could not find component on named entity '" +
                        (parentElem as IEntity).name + "'");
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

import com.pblabs.engine.entity.IEntityComponent;

final class PendingComponent
{
    public var item:IEntityComponent;
    public var name:String;
}
