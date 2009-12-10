package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.components.TickedComponent;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.Updatable;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.events.Event;
import flash.events.IEventDispatcher;

/**
 * A modification of GameObject.  Utilizes EntityComponents.
 * Rather that creating GameObjects with extra functionality via extending this class,
 * behaviour is built via adding IEntityComponents.
 *
 */
public class GameObjectEntity extends GameObject implements IEntity
{
    public static const ENTITY_DESTROYED :String = "EntityDestroyed";

    public function GameObjectEntity (name :String)
    {
        _name = name;
    }

    public function get components () :Array
    {
        return _components.components;
    }

    public function get dbComponent () :EntityAppmode
    {
        return db as EntityAppmode;
    }

    public function get eventDispatcher () :IEventDispatcher
    {
        return this;
    }

    public function get name () :String
    {
        return _name;
    }

//    public function set name (val :String) :void
//    {
//        _name = val;
//    }

    override public function get objectName () :String
    {
        return _name;
    }

    public function addComponent (component :IEntityComponent, componentName :String) :void
    {
//        if (isLiveObject) {
//            throw new Error("Components must be added before adding to the ObjectDB. " +
//                "(To add to the correct groups.  Components define groups).");
//        }

        if (!_components.addComponent(component, componentName)) {
            return;
        }

        if (isLiveObject) {
            dbComponent.addComponent(component);
            component.register(this, componentName);
            _components.doResetComponents();
        }

        //ObjectDB expects the groups defined on addObject, but that might not be the case for
        //IEntity
    }

    public function deserialize (xml :XML, registerComponents :Boolean = true) :void
    {
        // Note what entity we're deserializing to the Serializer.
        //        Serializer.instance.setCurrentEntity(this);

        //        for each (var componentXML :XML in xml.*) {
        //            // Error if it's an unexpected tag.
        //            if (componentXML.name().toString().toLowerCase() != "component") {
        //                log.error(this, "deserialize",
        //                    "Found unexpected tag '" + componentXML.name().toString() +
        //                    "', only <component/> is valid, ignoring tag. Error in entity '" + name + "'.");
        //                continue;
        //            }
        //
        //            var componentName :String = componentXML.attribute("name");
        //            var componentClassName :String = componentXML.attribute("type");
        //            var component :IEntityComponent = null;
        //
        //            if (componentClassName.length > 0) {
        //                component = TypeUtility.instantiate(componentClassName) as IEntityComponent;
        //                if (!component) {
        //                    log.error(this, "deserialize",
        //                        "Unable to instantiate component " + componentName + " of type " +
        //                        componentClassName + " on entity '" + name + "'.");
        //                    continue;
        //                }
        //
        //                if (!doAddComponent(component, componentName))
        //                    continue;
        //            } else {
        //                component = lookupComponentByName(componentName);
        //                if (!component) {
        //                    log.error(this, "deserialize",
        //                        "No type specified for the component " + componentName +
        //                        " and the component doesn't exist on a parent template for entity '" +
        //                        name + "'.");
        //                    continue;
        //                }
        //            }
        //
        //            Serializer.instance.deserialize(component, componentXML);
        //        }
        //
        //        if (registerComponents) {
        //            doRegisterComponents();
        //            doResetComponents();
        //        }
    }

    public function destroy () :void
    {
        if (isLiveObject) {
            destroySelf();
        }
    }

    public function doesPropertyExist (property :PropertyReference) :Boolean
    {
        return findProperty(property, false, _tempPropertyInfo, true) != null;
    }

    public function getProperty (property :PropertyReference, defaultVal :* = null) :*
    {
        // Look up the property.
        var info :PropertyInfo = findProperty(property, false, _tempPropertyInfo);
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

    public function initialize (name :String = null, alias :String = null) :void
    {
        _name = name;
        if (_name == null || _name == "")
            return;

        _alias = alias;

        //        NameManager.instance.addEntity(this, _name);
        //        if (_alias)
        //            NameManager.instance.addEntity(this, _alias);
    }

    public function lookupComponentByName (componentName :String) :IEntityComponent
    {
        return _components.lookupComponentByName(componentName);
    }

    public function lookupComponentByType (componentType :Class) :IEntityComponent
    {
        return _components.lookupComponentByType(componentType);
    }

    public function lookupComponentsByType (componentType :Class) :Array
    {
        return _components.lookupComponentsByType(componentType);
    }

    public function hasComponent (componentType :Class) :Boolean
    {
        return null != lookupComponentByType(componentType);
    }

    public function removeComponent (component :IEntityComponent) :void
    {
        if (!_components.doRemoveComponent(component)) {
            return;
        }
        dbComponent.removeComponent(component);
        component.unregister();
        _components.doResetComponents();
    }

    public function serialize (xml :XML) :void
    {
        //        for each (var component :IEntityComponent in _components) {
        //            var componentXML :XML = new XML(<Component/>);
        //            Serializer.instance.serialize(component, componentXML);
        //            xml.appendChild(componentXML);
        //        }
    }

    public function setProperty (property :PropertyReference, value :*) :void
    {
        // Look up and set.
        var info :PropertyInfo = findProperty(property, true, _tempPropertyInfo);
        if (info)
            info.setValue(value);

        // Clean up to avoid dangling references.
        _tempPropertyInfo.clear();
    }

    override public function getObjectGroup (groupNum :int) :String
    {
        var componentNames :Array = _components.names;
        if (componentNames.length > 0 && groupNum < componentNames.length) {
            return componentNames[groupNum];
        }
        return super.getObjectGroup(groupNum - componentNames.length);
    }

    override protected function addedToDB () :void
    {
        super.addedToDB();
        for each (var comp :IEntityComponent in _components.components) {
            dbComponent.addComponent(comp);
        }
        _components.doRegisterComponents(this);
    }

    override protected function destroyed () :void
    {
        // Give listeners a chance to act before we start destroying stuff.
        dispatchEvent(new Event(ENTITY_DESTROYED));
        super.destroyed();
        for each (var comp :IEntityComponent in _components.components) {
            dbComponent.removeComponent(comp);
        }
        _components.shutdown();
    }

    override protected function update (dt :Number) :void
    {
        super.update(dt);
        _components.update(dt);
    }

    protected var _alias :String = null;
    //Components are removed before we remove this object from its groups.
    protected var _components :ComponentList = new ComponentList();

    protected var _name :String = null;
    private var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

    protected static const log :Log = Log.getLog(GameObjectEntity);

    //    private function doAddComponent (component :IEntityComponent, componentName :String) :Boolean
    //    {
    //        if (componentName == "") {
    //            log.warning(this, "AddComponent",
    //                "A component name was not specified. This might cause problems later.");
    //        }
    //
    //        if (component.owner != null) {
    //            log.error(this, "AddComponent",
    //                "The component " + componentName + " already has an owner. (" + name + ")");
    //            return false;
    //        }
    //
    //        if (_components.get(componentName) != null) {
    //            log.error(this, "AddComponent",
    //                "A component with name " + componentName + " already exists on this entity (" +
    //                name + ").");
    //            return false;
    //        }
    //
    //        _components.put(componentName, component);
    //        return true;
    //    }

    private function findProperty (reference :PropertyReference, willSet :Boolean = false,
        providedPi :PropertyInfo = null, suppressErrors :Boolean = false) :PropertyInfo
    {
        // TODO: we use appendChild but relookup the results, can we just use return value?

        // Early out if we got a null property reference.
        if (!reference || reference.property == null || reference.property == "")
            return null;

        //        Profiler.enter("Entity.findProperty");

        // Must have a propertyInfo to operate with.
        if (!providedPi) {
            providedPi = new PropertyInfo();
        }

        // Cached lookups apply only to components.
        if (reference.cachedLookup && reference.cachedLookup.length > 0) {
            var cl :Array = reference.cachedLookup;
            var cachedWalk :* = lookupComponentByName(cl[0]);
            if (!cachedWalk) {
                if (!suppressErrors)
                    log.warning(this, "findProperty",
                        "Could not resolve component named '" + cl[0] + "' for property '" +
                        reference.property + "' with cached reference. ");
                //                Profiler.exit("Entity.findProperty");
                return null;
            }

            for (var i :int = 1; i < cl.length - 1; i++) {
                cachedWalk = cachedWalk[cl[i]];
                if (cachedWalk == null) {
                    if (!suppressErrors)
                        log.warning(this, "findProperty",
                            "Could not resolve property '" + cl[i] + "' for property reference '" +
                            reference.property + "' with cached reference");
                    //                    Profiler.exit("Entity.findProperty");
                    return null;
                }
            }

            var cachedPi :PropertyInfo = providedPi;
            cachedPi.propertyParent = cachedWalk;
            cachedPi.propertyName = (cl.length > 1) ? cl[cl.length - 1] : null;
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
            parentElem = lookupComponentByName(curLookup);
            if (!parentElem) {
                log.warning(this, "findProperty",
                    "Could not resolve component named '" + curLookup + "' for property '" +
                    reference.property + "'");
                //                Profiler.exit("Entity.findProperty");
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
                log.warning(this, "findProperty",
                    "Could not resolve named object named '" + curLookup + "' for property '" +
                    reference.property + "'");
                //                Profiler.exit("Entity.findProperty");
                return null;
            }

            // Get the component on it.
            curIdx++;
            curLookup = path[1];
            var comLookup :IEntityComponent =
                (parentElem as IEntity).lookupComponentByName(curLookup);
            if (!comLookup) {
                log.warning(this, "findProperty",
                    "Could not find component '" + curLookup + "' on named entity '" +
                    (parentElem as IEntity).name + "' for property '" + reference.property + "'");
                //                Profiler.exit("Entity.findProperty");
                return null;
            }
            parentElem = comLookup;
        } else if (startChar == "!") {
            // XML reference. Look it up inside the TemplateManager. We only support
            // templates and entities - no groups.
            //            parentElem = TemplateManager.instance.getXML(curLookup, "template", "entity");
            if (!parentElem) {
                log.warning(this, "findProperty",
                    "Could not find XML named '" + curLookup + "' for property '" + reference.
                    property + "'");
                //                Profiler.exit("Entity.findProperty");
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
                log.warning(this, "findProperty",
                    "Could not find component '" + path[1] + "' in XML template '" + path[0].
                    slice(1) + "' for property '" + reference.property + "'");
                //                Profiler.exit("Entity.findProperty");
                return null;
            }

            // Get ready to search the rest.
            parentElem = nextElem;

            // Indicate we are dealing with xml.
            isTemplateXML = true;
        } else {
            log.warning(this, "findProperty",
                "Got a property path that doesn't start with !, #, or @. Started with '" +
                startChar + "' for property '" + reference.property + "'");
            //            Profiler.exit("Entity.findProperty");
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
                if (parentElem is XML || parentElem is XMLList)
                    parentElem = parentElem.child(curLookup);
                else
                    parentElem = parentElem[curLookup];
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
                log.warning(this, "findProperty",
                    "Could not resolve property '" + curLookup + "' for property reference '" +
                    reference.property + "'");
                //                Profiler.exit("Entity.findProperty");
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
            //            Profiler.exit("Entity.findProperty");
            return pi;
        }

        //        Profiler.exit("Entity.findProperty");
        return null;
    }
}
}

import com.pblabs.engine.components.TickedComponent;
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.threerings.flashbang.Updatable;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.DebugUtil;
final class PropertyInfo
{
    public var propertyName :String = null;
    public var propertyParent :Object = null;

    public function clear () :void
    {
        propertyParent = null;
        propertyName = null;
    }

    public function getValue () :*
    {
        try {
            if (propertyName)
                return propertyParent[propertyName];
            else
                return propertyParent;
        } catch (e :Error) {
            return null;
        }
    }

    public function setValue (value :*) :void
    {
        propertyParent[propertyName] = value;
    }
}

final class ComponentList
{

    public function get components () :Array
    {
        return _components;
    }

    public function get names () :Array
    {
        return _componentMap.keys();
    }

    public function addComponent (component :IEntityComponent, componentName :String) :Boolean
    {

        if (componentName == "") {
            log.warning("AddComponent",
                "A component name was not specified. This might cause problems later.");
        }

        if (component.owner != null) {
            log.error(this, "AddComponent",
                "The component " + componentName + " already has an owner. (" + component.owner.
                name + ")");
            return false;
        }

        if (_componentMap.get(componentName) != null) {
            log.error(this, "AddComponent", component,
                "A component with name " + componentName + " already exists on this entity " +
                ". " + DebugUtil.mapToString(_componentMap));
            return false;
        }

        _components.push(component);
        _componentMap.put(componentName, component);
        for each (var component :IEntityComponent in _components) {
            component.reset();
        }
        return true;
    }

    /**
     * Register any unregistered components on this entity. Useful when you are
     * deferring registration (for instance due to template processing).
     */
    public function doRegisterComponents (entity :IEntity) :void
    {
        for each (var component :IEntityComponent in _components) {
            // Skip ones we have already registered.
            if (component.isRegistered) {
                continue;
            }
            component.register(entity, component.name);
        }
    }

    public function doRemoveComponent (component :IEntityComponent) :Boolean
    {
        if (component.owner != this) {
            log.error(this, "AddComponent",
                "The component " + component.name + " is not owned by this entity. (" + component.
                owner.name + ")");
            return false;
        }

        if (!_components.get(component.name)) {
            log.error(this, "AddComponent",
                "The component " + component.name + " was not found on this entity. (" + component.
                owner.name + ")");
            return false;
        }
        ArrayUtil.removeAll(_components, component);
        _componentMap.remove(component.name);
        return true;
    }

    public function doResetComponents () :void
    {
        for each (var component :IEntityComponent in _components) {
            component.reset();
        }
    }

    public function isComponent (componentName :String) :Boolean
    {
        return _componentMap.get(componentName) != null;
    }

    public function lookupComponentByName (componentName :String) :IEntityComponent
    {
        return _componentMap.get(componentName) as IEntityComponent;
    }

    public function lookupComponentByType (componentType :Class) :IEntityComponent
    {
        for each (var c :IEntityComponent in _components) {
            if (c is componentType)
                return c;
        }

        return null;
    }

    public function lookupComponentsByType (componentType :Class) :Array
    {
        var list :Array = [];

        for each (var c :IEntityComponent in _components) {
            if (c is componentType)
                list.push(c);
        }

        return list;
    }

    public function shutdown () :void
    {
        for each (var c :IEntityComponent in _components) {
            c.unregister();
        }
        _components = null;
        _componentMap.clear();
    }

    public function update (dt :Number) :void
    {
        for each (var c :IEntityComponent in _components) {
            if (c is Updatable) {
                Updatable(c).update(dt);
            } else if (c is TickedComponent) {
                TickedComponent(c).onTick(dt);
            }
        }
    }
    protected var _componentMap :Map = Maps.newMapOf(String);

    protected var _components :Array = [];
    protected static const log :Log = Log.getLog(ComponentList);
}

