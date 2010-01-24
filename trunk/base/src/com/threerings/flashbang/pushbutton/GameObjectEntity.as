package com.threerings.flashbang.pushbutton {
	import com.pblabs.engine.core.ITickedObject;
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.IEntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	import com.threerings.flashbang.GameObject;
	import com.threerings.flashbang.Updatable;
	import com.threerings.pbe.tasks.TaskComponent;
	import com.threerings.util.ArrayUtil;
	import com.threerings.util.ClassUtil;
	import com.threerings.util.Log;
	import com.threerings.util.Map;
	import com.threerings.util.Maps;
	import com.threerings.util.Predicates;
	import com.threerings.util.StringUtil;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	
	import net.amago.pbe.PushbuttonConsts;
	import net.amago.util.EventDispatcherNonCloning;
	
	/**
	 * A modification of GameObject.  Utilizes EntityComponents.
	 * Rather that creating GameObjects with extra functionality via extending this class,
	 * behaviour is built via adding IEntityComponents.
	 *
	 */
	public class GameObjectEntity extends GameObject implements IEntityExtended
	{
		public static const GROUP_ENTITY :String = "EntityGroup";
		
		public function GameObjectEntity (name :String = null)
		{
			_name = name;
			addComponent(new TaskComponent(), TaskComponent.COMPONENT_NAME);
		}
		
		public function get alias () :String
		{
			return null;
		}
		
		public function get components () :Array
		{
			return _components.concat();
		}
		
		public function get dbComponent () :EntityAppmode
		{
			return db as EntityAppmode;
		}
		
		public function get deferring():Boolean
		{
			return _deferring;
		}
		
		public function set deferring(value:Boolean):void
		{
			if(_deferring == true && value == false)
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
			_dispatcher = val;
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
				var p:PendingComponent = new PendingComponent();
				p.item = component;
				p.name = componentName;
				_deferredComponents.push(p);
				deferring = true;
				return true;
			}
			
			return true;
		}
		
		public function deserialize (xml :XML, registerComponents :Boolean = true) :void
		{
		}
		
		//    public function addComponent (component:IEntityComponent, componentName:String) :void
		//    {
		//    }
		
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
		
		public function getEntitiesInGroup (groupName :String) :Array //<IEntity>
		{
			return db.getObjectsInGroup(groupName).filter(Predicates.createIs(IEntity));
		}
		
		public function getEntity (entityName :String) :IEntityExtended
		{
			return db.getObjectNamed(entityName) as IEntityExtended;
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
		
		public function hasComponent (componentType :Class) :Boolean
		{
			return null != lookupComponentByType(componentType);
		}
		
		public function initialize (name :String = null, alias :String = null) :void
		{
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
			if (!_componentMap.containsKey(component.name)) {
				return;
			}
			
			//        if (!_components.doRemoveComponent(component)) {
			//            return;
			//        }
			//        dbComponent.removeComponent(component);
			component.unregister();
			
			_componentMap.remove(component.name);
			ArrayUtil.removeFirst(_components, component);
			doResetComponents();
		}
		
		public function serialize (xml :XML) :void
		{
		}
		
		public function setProperty (property :PropertyReference, value :*) :void
		{
			// Look up and set.
			var info :PropertyInfo = findProperty(property, true, _tempPropertyInfo);
			if (info != null) {
				info.setValue(value);
			} else {
				log.warning("setProperty", "property", property, "info", info);
			}
			
			// Clean up to avoid dangling references.
			_tempPropertyInfo.clear();
		}
		
		override public function destroySelf () :void
		{
			if (isLiveObject) {
				super.destroySelf();
			}
		}
		
		//GameObjectEntity groups include the component classnames.
		override public function getObjectGroup (groupNum :int) :String
		{
			if (groupNum == 0) {
				return GROUP_ENTITY;
			}
			var numComponents :int = _components != null ? _components.length : 0;
			if (numComponents > 0 && groupNum - 1 < numComponents) {
				return ClassUtil.getClassName(_components[groupNum - 1]);
			}
			return super.getObjectGroup(groupNum - (numComponents + 1));
		}
		
		override protected function addedToDB () :void
		{
			super.addedToDB();
			//        for each (var comp :IEntityComponent in _components.components) {
			//            dbComponent.addComponent(comp);
			//        }
			//        doRegisterComponents();
			deferring = false;
			//        _components.doRegisterComponents(this);
		}
		
		override protected function destroyed () :void
		{
			// Give listeners a chance to act before we start destroying stuff.
			dispatchEvent(new Event(PushbuttonConsts.EVENT_ENTITY_DESTROYED));
			super.destroyed();
			
			for each (var c :IEntityComponent in _components) {
				c.unregister();
			}
			_components = null;
			_componentMap.clear();
			//        for each (var comp :IEntityComponent in _components.components) {
			//            dbComponent.removeComponent(comp);
			//        }
			//        _components.shutdown();
		}
		
		override protected function update (dt :Number) :void
		{
			super.update(dt);
			for each (var c :IEntityComponent in _components) {
				if (c is Updatable) {
					Updatable(c).update(dt);
				} else if (c is ITickedObject) {
					ITickedObject(c).onTick(dt);
				}
			}
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
		
		override public function toString() : String
		{
			if (stringFunc != null) {
				return stringFunc(this) as String;
			} else if (ClassUtil.getClass(this) != GameObjectEntity) {
				return StringUtil.simpleToString(this);
			} else {
				return String(_components.length > 1 ? _components[1] : this);//String the first component
			}
		}
		
		protected var _componentMap :Map = Maps.newMapOf(String);
		protected var _components :Array = [];
		protected var _dispatcher :IEventDispatcher = new EventDispatcherNonCloning();
		
		protected var _name :String = null;
		private var _tempPropertyInfo :PropertyInfo = new PropertyInfo();
		
		public var stringFunc :Function;
		
		protected static const log :Log = Log.getLog(GameObjectEntity);
		protected var _deferredComponents:Array = new Array();
		private var _deferring:Boolean = true;
		
		private function traceStack () :void 
		{
			try {
				throw new Error();
			} catch (e :Error) {
				trace(e.getStackTrace());
			}
		}
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
			
			//Debugging
			var isTraceStack :Boolean = true;
			
			
			// Cached lookups apply only to components.
			if (reference.cachedLookup && reference.cachedLookup.length > 0) {
				var cl :Array = reference.cachedLookup;
				var cachedWalk :* = lookupComponentByName(cl[0]);
				if (!cachedWalk) {
					if (!suppressErrors) {
						log.warning(this, "findProperty",
							"Could not resolve component named '" + cl[0] + "' for property '" +
							reference.property + "' with cached reference. ");
						if (isTraceStack) {traceStack();}
					}
					//                Profiler.exit("Entity.findProperty");
					return null;
				}
				
				for (var i :int = 1; i < cl.length - 1; i++) {
					
					if (cachedWalk is IEntity) {
						cachedWalk = IEntity(cachedWalk).lookupComponentByName(cl[i]);	
					} else {
						cachedWalk = cachedWalk[cl[i]];
					}
					
					
					if (cachedWalk == null) {
						if (!suppressErrors) {
							log.warning(this, "findProperty",
								"Could not resolve property '" + cl[i] + "' for property reference '" +
								reference.property + "' with cached reference");
							if (isTraceStack) {traceStack();}
						}
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
					if (isTraceStack) {traceStack();}
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
					if (isTraceStack) {traceStack();}
					//                Profiler.exit("Entity.findProperty");
					return null;
				}
				
				// Get the component on it.
				curIdx++;
				curLookup = path[1];
				var comLookup :IEntityComponent =
					(parentElem as IEntityExtended).lookupComponentByName(curLookup);
				if (!comLookup) {
					log.warning(this, "findProperty",
						"Could not find component '" + curLookup + "' on named entity '" +
						(parentElem as IEntityExtended).name + "' for property '" + reference.property +
						"'");
					if (isTraceStack) {traceStack();}
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
					if (isTraceStack) {traceStack();}
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
					if (isTraceStack) {traceStack();}
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
				if (isTraceStack) {traceStack();}
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
					log.warning(this, "findProperty",
						"Could not resolve property '" + curLookup + "' for property reference '" +
						reference.property + "'");
					if (isTraceStack) {traceStack();}
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

//import com.pblabs.engine.entity.IEntityComponent;
//import flash.events.IEventDispatcher;
//import com.threerings.flashbang.Updatable;
//import com.threerings.util.ArrayUtil;
//import com.threerings.util.DebugUtil;
//import com.threerings.util.Log;
//import com.threerings.util.Map;
//import com.threerings.util.Maps;
//final class PropertyInfo
//{
//    public var propertyName :String = null;
//    public var propertyParent :Object = null;
//
//    public function clear () :void
//    {
//        propertyParent = null;
//        propertyName = null;
//    }
//
//    public function getValue () :*
//    {
//        try {
//            if (propertyName)
//                return propertyParent[propertyName];
//            else
//                return propertyParent;
//        } catch (e :Error) {
//            return null;
//        }
//    }
//
//    public function setValue (value :*) :void
//    {
//        propertyParent[propertyName] = value;
//    }
//}

import com.pblabs.engine.entity.IEntityComponent;

final class PendingComponent
{
	public var item:IEntityComponent;
	public var name:String;
}