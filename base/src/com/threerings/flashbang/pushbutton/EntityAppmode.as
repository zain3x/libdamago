package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.AppMode;
import com.threerings.util.Log;

public class EntityAppmode extends AppMode
{
    public static const OBJECT_ADDED :String = "objectAdded";
    public static const OBJECT_REMOVED :String = "objectRemoved";
//    public static const SINGLETON_ENTITY_NAME :String = "!";

    public function EntityAppmode ()
    {
        super();

//        addSceneObject(new ViewEntity());
//
//        var physName :String = "sim";
//        var phyEntity :GameObjectEntity = new GameObjectEntity();
//        phyEntity.name = "blah";
////        phyEntity.name = physName;
//        phyEntity.addComponent(new Box2DManagerComponent(), physName);
//        addObject(phyEntity);
//
////        trace("Prop=" + phyEntity.getProperty(new PropertyReference("#blah.sim.gravity")));
//
//
//        var ball1 :GameObjectEntity = new GameObjectEntity();
//        var comp :Box2DSpatialComponent = new Box2DSpatialComponent();
//        comp.canMove = true;
//        comp.managerReference = new PropertyReference("#" + phyEntity.name + "." + physName);
//        ball1.addComponent(comp, "");
//        addObject(ball1);
//        comp.linearVelocity = new Point(2, 2);


//        var view :SceneView = new SceneView(300, 300);
//
//        var scene :Scene = new Scene();
//        scene.sceneView = view;
//        var sceneName :String = "scene";
//        var layerName :String = "someLayer";
//        var layer :SceneLayer = new SceneLayerYOrdering();
//        scene.addLayer(layer, layerName);
//        addComponentViaSameNamedEntity(scene, sceneName);
//        modeSprite.addChild(view);
//
//        scene.zoom = 0.5;
//
//        var sceneRef :PropertyReference = scene.componentReference;
//
//
//
//
//        var obj :GameObjectEntity = new GameObjectEntity();
//
//        //The location component
//        var location :LocationComponentBasic = new LocationComponentBasic();
//        location.x = 100;
//        location.y = 100;
//        var locationName :String = "location";
//        obj.addComponent(location, locationName);
//
//        //The display component
//        var circle :Sprite = new Sprite();
//        DebugUtil.fillDot(circle);
//        var sceneComponent :SceneEntityComponent = new SceneEntityComponent();
//        var sceneComponentName :String = "sceneComponent";
//        sceneComponent.displayObject = circle;
//        sceneComponent.sceneLayerName = layerName;
//        obj.addComponent(sceneComponent, sceneComponentName);
//
//
//        //Link the display to the location component
//        sceneComponent.xProperty = new PropertyReference("@location.x");
//        sceneComponent.yProperty = new PropertyReference("@location.y");
//
//        //Add to the db
//        this.addObject(obj);
//
//        //Add to the scene
//        scene.addSceneComponent(sceneComponent);
//
//
//        //Start moving
//        obj.addTask(LocationTaskComponent.CreateLinear(200, 200, 5, location));
//
//        DebugUtil.traceDisplayChildren(modeSprite);
//        trace("Scene ref=" + obj.getProperty(sceneRef));

    }
//
//    public function getEntity (predicate :Function) :IEntity
//    {
//        for each (var ref :GameObjectRef in getObjectRefsInGroup(GameObjectEntity.GROUP_ENTITY)) {
//            if (ref.object != null && predicate(ref.object)) {
//                return ref.object as IEntity;
//            }
//        }
//        return null;
//    }
//    public function getEntities (predicate :Function = null) :Array
//    {
//        var arr :Array = [];
//        for each (var ref :GameObjectRef in getObjectRefsInGroup(GameObjectEntity.GROUP_ENTITY)) {
//            if (ref.object == null) {
//                continue;
//            }
//            if (predicate == null || predicate(ref.object)) {
//                arr.push(ref.object)
//            }
//        }
//        return arr;
//    }
//    public function getComponent (predicate :Function) :IEntityComponent
//    {
//        for each (var ref :GameObjectRef in getObjectRefsInGroup(GameObjectEntity.GROUP_ENTITY)) {
//            if (ref.object != null && predicate(ref.object)) {
//                for each (var comp :IEntityComponent in GameObjectEntity(ref.object).components) {
//                    if (predicate(comp)) {
//                        return comp;
//                    }
//                }
//            }
//        }
//        return null;
//    }
//    public function getComponents (predicate :Function = null) :Array
//    {
//        var arr :Array = [];
//        for each (var ref :GameObjectRef in getObjectRefsInGroup(GameObjectEntity.GROUP_ENTITY)) {
//            if (ref.object != null) {
//                for each (var comp :IEntityComponent in GameObjectEntity(ref.object).components) {
//                    if (predicate == null || predicate(comp)) {
//                        arr.push(comp);
//                    }
//                }
//            }
//        }
//        return arr;
//    }

    public function get elapsedTime () :Number
    {
        return _elapsedTime;
    }

//    public function get instance () :EntityAppmode
//    {
//        return this;
//    }
//
//    public function get NameManager () :EntityAppmode
//    {
//        return this;
//    }

//    public function addComponentViaSameNamedEntity (comp :IEntityComponent)
//        :GameObjectEntity
//    {
//        trace("addComponentViaSameNamedEntity");
//        var obj :GameObjectEntity = getObjectNamed(name) as GameObjectEntity;
//
//        if (null == obj) {
//            obj = new GameObjectEntity(name);
//            addObject(obj);
//        }
//        obj.addComponent(comp);
//        return obj;
//    }

    public function addSingletonComponent (comp :IEntityComponent, compName :String)
        :IEntity
    {
        log.info("addSingletonComponent", "comp", comp);
		
		var obj :GameObjectEntity = new GameObjectEntity(compName);
//		obj.addComponent(new TaskComponent(), TaskComponent.COMPONENT_NAME);
		obj.addComponent(comp, compName);
		addObject(obj);
		return obj;
		
//        var obj :GameObjectEntity = singletonEntity;
//
//        if (null == obj) {
//            obj = new GameObjectEntity(SINGLETON_ENTITY_NAME);
//			//Add tasker, even though the game object has the same
//			obj.addComponent(new TaskComponent(), TaskComponent.COMPONENT_NAME); 
//            addObject(obj);
//        }
//        obj.addComponent(comp, compName);
//        return "#" + SINGLETON_ENTITY_NAME + "." + compName;
    }
	
//	public function getSingletonProperty (prop :String, defaultValue :* = null) :*
//	{
//		return singletonEntity.getProperty(new PropertyReference(prop), defaultValue);
//	}
//	
//	public function setSingletonProperty (prop :String, val :*) :void
//	{
//		return singletonEntity.setProperty(new PropertyReference(prop), val);
//	}

    public function getSingletonComponent (name :String) :IEntityComponent
    {
		var entity :IEntity = getObjectNamed(name) as IEntity;
		if (entity == null) {
			return null;
		}
		return entity.lookupComponentByName(name);
//        var obj :GameObjectEntity = singletonEntity;
//
//        if (null == obj) {
//            return null;
//        }
//        return obj.lookupComponentByName(name);
    }
	
//	public function get singletonEntity () :GameObjectEntity
//	{
//		return getObjectNamed(SINGLETON_ENTITY_NAME) as GameObjectEntity;
//	}

    //Don't modify the array!
//    public function getComponentsOfType (clazz :Class) :Array
//    {
//        return _groupedComponentsByType.get(clazz) as Array;
//    }

//    public function getFirstComponentOfType (clazz :Class) :*
//    {
//        var arr :Array = _groupedComponentsByType.get(clazz) as Array;
//        if (null == arr) {
//            return null;
//        }
//        return arr[0];
//    }
//
//    public function getFirstNamedComponent (name :String) :IEntityComponent
//    {
//        var arr :Array = _groupedComponentsByName.get(name) as Array;
//        if (null == arr) {
//            return null;
//        }
//        return arr[0];
//    }

//    public function getNamedComponents (name :String) :Array
//    {
//        return _groupedComponentsByName.get(name) as Array;
//    }

//    public function lookupComponentByName (entityName :String,
//        componentName :String) :IEntityComponent
//    {
//        var entity :IEntity = getObjectNamed(entityName) as IEntity;
//        if (entity == null) {
//            return null;
//        }
//
//        return entity.lookupComponentByName(componentName);
//    }

//    public function getComponent (componentName :String) :IEntityComponent
//    {
//        var arr :Array = _groupedComponentsByName.get(componentName) as Array;
//        if (arr != null && arr.length > 0) {
//            return arr[0] as IEntityComponent;
//        }
//
//        return null;
//    }
//
//    public function getComponents (componentName :String) :Array
//    {
//        return _groupedComponentsByName.get(componentName) as Array;
//    }

//    override public function addObject (obj :GameObject) :GameObjectRef
//    {
//        var ref :GameObjectRef = super.addObject(obj);
//        if (obj is IEntity) {
//            for each (var component :IEntityComponent in GameObjectEntity(obj).components) {
//                addComponent(component);
//            }
//        }
//        dispatchEvent(new ValueEvent(OBJECT_ADDED, obj));
//        return ref;
//    }
//
//    override public function destroyObject (ref :GameObjectRef) :void
//    {
//        dispatchEvent(new ValueEvent(OBJECT_REMOVED, ref.object));
//        super.destroyObject(ref);
//    }

    override public function update (dt :Number) :void
    {
        _elapsedTime += dt;
        super.update(dt);
    }
//
//    override protected function endUpdate (dt :Number) :void
//    {
//        super.endUpdate(dt);
//        // clean out all components that were removed during the update loop
//        if (_componentsToRemove != null && _componentsToRemove.length > 0) {
//            finalizeComponentRemoval();
//        }
//    }

//    internal function addComponent (component :IEntityComponent) :void
//    {
//        var name :String = component.name;
//        var names :Array = _groupedComponentsByName.get(name) as Array;
//        if (null == names) {
//            names = [component];
//            _groupedComponentsByName.put(name, names)
//        } else {
//            if (!ArrayUtil.contains(names, component)) {
//                names.push(component);
//            }
//        }
//
//        var clazz :Class = ClassUtil.getClass(component);
//        var classArray :Array = _groupedComponentsByType.get(clazz) as Array;
//        if (null == classArray) {
//            classArray = [component];
//            _groupedComponentsByType.put(clazz, classArray)
//        } else {
//            if (!ArrayUtil.contains(classArray, component)) {
//                classArray.push(component);
//            }
//        }
//    }

//    protected function finalizeComponentRemoval () :void
//    {
//        for each (var component :IEntityComponent in _componentsToRemove) {
//            var clazz :Class = ClassUtil.getClass(component);
//            var name :String = component.name;
//            var nameArray :Array = _groupedComponentsByName.get(name) as Array;
//            var classArray :Array = _groupedComponentsByType.get(clazz) as Array;
//
//            if (null != nameArray) {
//                ArrayUtil.removeFirst(nameArray, component);
//            }
//            if (null != classArray) {
//                ArrayUtil.removeFirst(classArray, component);
//            }
//
//        }
//        _componentsToRemove = [];
//    }
//
//    internal function removeComponent (component :IEntityComponent) :void
//    {
//        _componentsToRemove.push(component);
//    }

//    protected var _componentsToRemove :Array = [];

    //    private function CreateScene () :void
    //    {
    //        var Scene :IEntity = new GameObjectEntity(); // Allocate our Scene entity
    //        Scene.initialize("Scene"); // Register with the name "Scene"
    //        var Spatial :BasicSpatialManager2D = new BasicSpatialManager2D(); // Allocate our Spatial DB component
    //        Scene.addComponent(Spatial, "Spatial"); // Add to Scene with name "Spatial"
    //
    //        var Renderer :Scene2DComponent = new Scene2DComponent(); // Allocate our renderering component
    //
    //        Renderer.spatialDatabase = Spatial; // Point renderer at Spatial (for entity location information)
    //
    //        var View :SceneViewFlashbang = new SceneViewFlashbang(); // Create a view for our Renderer
    //        View.width = 800; // Set the width of our Scene View
    //        View.height = 600; // Set the height of our Scene View
    //        Renderer.sceneView = View; // Point the Renderer's SceneView at the view we just created.
    //
    //        Renderer.position = new Point(0, 0); // Point the camera (center of render view) at 0,0
    //
    //        Renderer.renderMask = new ObjectType("Renderable"); // Set the render mask to only draw entities explicitly marked as "Renderable"
    //
    //        Scene.addComponent(Renderer, "Renderer"); // Add our Renderer component to the scene entity with the name "Renderer"
    //    }

    //    private function CreateHero () :void
    //    {
    //        var Hero :GameObjectEntity = new GameObjectEntity(); // Allocate an entity for our hero avatar
    //        Hero.initialize("Hero"); // Register the entity with PBE under the name "Hero"
    //        addObject(Hero);
    //
    //        var Spatial :SimpleSpatialComponent = new SimpleSpatialComponent(); // Create our spatial component
    //
    //        // Do a named lookup to register our hero with the scene spatial database
    //        Spatial.spatialManager = NameManager.instance.lookupComponentByName("Scene",
    //            "Spatial") as ISpatialManager2D;
    //
    //        Spatial.objectMask = new ObjectType("Renderable"); // Set a mask flag for this entity as "Renderable" to be seen by the scene Renderer
    //        Spatial.position = new Point(0, 0); // Set our hero's spatial position as 0,0
    //        Spatial.size = new Point(50, 50); // Set our hero's size as 50,50
    //
    //        Hero.addComponent(Spatial, "Spatial"); // Add our spatial component to the Hero entity with the name "Spatial"
    //
    //        // Create a simple render component to display our entity
    //        var Render :SimpleShapeRenderComponent = new SimpleShapeRenderComponent();
    //
    //        Render.showCircle = true; // Specify to draw the entity as a circle
    //        Render.radius = 25; // Mark the radius of the circle as 25
    //        // Point the render component to this entity's Spatial component for position information
    //        Render.positionReference = new PropertyReference("@Spatial.position");
    //        // Point the render component to this entity's Spatial component for rotation information
    //        Render.rotationReference = new PropertyReference("@Spatial.rotation");
    //
    //        Hero.addComponent(Render, "Render"); // Add our render component to the Hero entity with the name "Render"
    //    }

//    internal function updateGroups (entity :GameObjectEntity) :void
//    {
//        if (entity == null || !entity.isLiveObject) {
//            return;
//        }
//
//        for each (var c :IEntityComponent in entity.components) {
//            var groupName :String = c.name;
//            var groupArray :Array = (_groupedObjects.get(groupName) as Array);
//            if (null == groupArray) {
//                groupArray = [];
//                _groupedObjects.put(groupName, groupArray);
//            }
//
//            if (!ArrayUtil.contains(groupArray, entity.ref)) {
//                groupArray.push(entity.ref);
//            }
//        }
//    }
	
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
	
//	protected function findProperty (reference :PropertyReference, willSet :Boolean = false,
//		   providedPi :PropertyInfo = null, suppressErrors :Boolean = false) :PropertyInfo
//	{
//		// TODO: we use appendChild but relookup the results, can we just use return value?
//		
//		// Early out if we got a null property reference.
//		if (!reference || reference.property == null || reference.property == "")
//			return null;
//		
//		//        Profiler.enter("Entity.findProperty");
//		
//		// Must have a propertyInfo to operate with.
//		if (!providedPi) {
//			providedPi = new PropertyInfo();
//		}
//		
//		
//		// Split up the property reference.
//		var propertyName :String = reference.property;
//		var path :Array = propertyName.split(".");
//		
//		// Distinguish if it is a component reference (@), named object ref (#), or
//		// an XML reference (!), and look up the first element in the path.
//		var isTemplateXML :Boolean = false;
//		var itemName :String = path[0];
//		var curIdx :int = 1;
//		var startChar :String = itemName.charAt(0);
//		var curLookup :String = itemName.slice(1);
//		var parentElem :*;
//		if (startChar == "@") {
//			log.error(this, "findProperty",
//				"No component lookups on the ObjectDB for property '" +
//				reference.property + "'");
//			return null;
//		} else if (startChar == "#") {
//			// Named object reference. Look up the entity in the NameManager.
//			//            parentElem = NameManager.instance.lookup(curLookup);
//			parentElem = getObjectNamed(curLookup);
//			if (!parentElem) {
//				log.warning(this, "findProperty",
//					"Could not resolve named object named '" + curLookup + "' for property '" +
//					reference.property + "'");
//				try {
//					throw new Error();
//				} catch (e :Error) {
//					trace(e.getStackTrace());
//				}
//				//                Profiler.exit("Entity.findProperty");
//				return null;
//			}
//			
//			// Get the component on it.
//			curIdx++;
//			curLookup = path[1];
//			var comLookup :IEntityComponent =
//				(parentElem as IEntity).lookupComponentByName(curLookup);
//			if (!comLookup) {
//				log.warning(this, "findProperty",
//					"Could not find component '" + curLookup + "' on named entity '" +
//					(parentElem as IEntityExtended).name + "' for property '" + reference.property +
//					"'");
//				//                Profiler.exit("Entity.findProperty");
//				return null;
//			}
//			parentElem = comLookup;
//		} else if (startChar == "!") {
//			// XML reference. Look it up inside the TemplateManager. We only support
//			// templates and entities - no groups.
//			//            parentElem = TemplateManager.instance.getXML(curLookup, "template", "entity");
//			if (!parentElem) {
//				log.warning(this, "findProperty",
//					"Could not find XML named '" + curLookup + "' for property '" + reference.
//					property + "'");
//				//                Profiler.exit("Entity.findProperty");
//				return null;
//			}
//			
//			// Try to find the specified component.
//			curIdx++;
//			var nextElem :* = null;
//			for each (var cTag :*in parentElem.*) {
//				if (cTag.@name == path[1]) {
//					nextElem = cTag;
//					break;
//				}
//			}
//			
//			// Create it if appropriate.
//			if (!nextElem && willSet) {
//				// Create component tag.
//				(parentElem as XML).appendChild(<component name={path[1]}/>);
//				
//				// Look it up again.
//				for each (cTag in parentElem.*) {
//					if (cTag.@name == path[1]) {
//						nextElem = cTag;
//						break;
//					}
//				}
//			}
//			
//			// Error if we don't have it!
//			if (!nextElem) {
//				log.warning(this, "findProperty",
//					"Could not find component '" + path[1] + "' in XML template '" + path[0].
//					slice(1) + "' for property '" + reference.property + "'");
//				//                Profiler.exit("Entity.findProperty");
//				return null;
//			}
//			
//			// Get ready to search the rest.
//			parentElem = nextElem;
//			
//			// Indicate we are dealing with xml.
//			isTemplateXML = true;
//		} else {
//			log.warning(this, "findProperty",
//				"Got a property path that doesn't start with !, #, or @. Started with '" +
//				startChar + "' for property '" + reference.property + "'");
//			//            Profiler.exit("Entity.findProperty");
//			return null;
//		}
//		
//		// Make sure we have a field to look up.
//		if (curIdx < path.length)
//			curLookup = path[curIdx++] as String;
//		else
//			curLookup = null;
//		
//		// Do the remainder of the look up.
//		while (curIdx < path.length && parentElem) {
//			// Try the next element in the path.
//			var oldParentElem :* = parentElem;
//			try {
//				if (parentElem is XML || parentElem is XMLList)
//					parentElem = parentElem.child(curLookup);
//				else
//					parentElem = parentElem[curLookup];
//			} catch (e :Error) {
//				parentElem = null;
//			}
//			
//			// Several different possibilities that indicate we failed to advance.
//			var gotEmpty :Boolean = false;
//			if (parentElem == undefined)
//				gotEmpty = true;
//			if (parentElem == null)
//				gotEmpty = true;
//			if (parentElem is XMLList && parentElem.length() == 0)
//				gotEmpty = true;
//			
//			// If we're going to set and it's XML, create the field.
//			if (willSet && isTemplateXML && gotEmpty && oldParentElem) {
//				oldParentElem.appendChild(<{curLookup}/>);
//				parentElem = oldParentElem.child(curLookup);
//				gotEmpty = false;
//			}
//			
//			if (gotEmpty) {
//				log.warning(this, "findProperty",
//					"Could not resolve property '" + curLookup + "' for property reference '" +
//					reference.property + "'");
//				try {
//					throw new Error();
//				} catch (e :Error) {
//					trace(e.getStackTrace());
//				}
//				//                Profiler.exit("Entity.findProperty");
//				return null;
//			}
//			
//			// Advance to next element in the path.
//			curLookup = path[curIdx++] as String;
//		}
//		
//		// Did we end up with a match?
//		if (parentElem) {
//			var pi :PropertyInfo = providedPi;
//			pi.propertyParent = parentElem;
//			pi.propertyName = curLookup;
//			//            Profiler.exit("Entity.findProperty");
//			return pi;
//		}
//		
//		//        Profiler.exit("Entity.findProperty");
//		return null;
//	}

    /** Elapsed time for this ObjectDB */
    protected var _elapsedTime :Number = 0;
	
	protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

//    /** stores a mapping from String to Array */
//    protected var _groupedComponentsByName :Map = Maps.newMapOf(String);
//
//    /** stores a mapping from Class to Array */
//    protected var _groupedComponentsByType :Map= Maps.newMapOf(Class);

    protected static const log :Log = Log.getLog(EntityAppmode);
}
}