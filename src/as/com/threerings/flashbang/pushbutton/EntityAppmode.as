package com.threerings.flashbang.pushbutton {
	import com.pblabs.engine.entity.IEntity;
	import com.pblabs.engine.entity.IEntityComponent;
	import com.pblabs.engine.entity.PropertyReference;
	import com.threerings.flashbang.AppMode;
	import com.threerings.flashbang.GameObject;
	import com.threerings.flashbang.GameObjectRef;
	import com.threerings.util.ArrayUtil;
	import com.threerings.util.Log;
	public class EntityAppmode extends AppMode
	{
		public static const OBJECT_ADDED :String = "objectAdded";
		public static const OBJECT_REMOVED :String = "objectRemoved";
		
		public function EntityAppmode ()
		{
			super();
		}
		
		public function get allObjects () :Array
		{
			return _allObjects;
		}
		
		//	public function getAllObjects () :Array
		//	{
		//		var objs :Array = [];
		//		var ref :GameObjectRef = _listHead;
		//		while (null != ref) {
		//			if (!ref.isNull) {
		//				objs.push(ref.object);
		//			}
		//			ref = ref._next;
		//		}
		//		return objs;
		//	}
		
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
		
		public function addSingletonComponent (comp :IEntityComponent, compName :String)
			:IEntity
		{
			log.info("addSingletonComponent", "comp", comp);
			//		Profiler.enter(compName);
			var obj :GameObjectEntity = new GameObjectEntity(compName);
			obj.addComponent(comp, compName);
			addObject(obj);
			//		Profiler.exit(compName);
			return obj;
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
			var ref :GameObjectRef = super.addObject(obj);
			_allObjects.push(ref);
			return ref;
		}
		
		override public function destroyObject (ref :GameObjectRef) :void
		{
			super.destroyObject(ref);
			ArrayUtil.removeFirst(_allObjects, ref);
		}
		
		override public function update (dt :Number) :void
		{
			_elapsedTime += dt;
			super.update(dt);
		}
		
		protected var _allObjects :Array = [];
		
		
		
		/** Elapsed time for this ObjectDB */
		protected var _elapsedTime :Number = 0;
		protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();
		
		protected static const log :Log = Log.getLog(EntityAppmode);
	}
}