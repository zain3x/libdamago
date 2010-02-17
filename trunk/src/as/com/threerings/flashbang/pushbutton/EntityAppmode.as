package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntity;
import com.pblabs.engine.entity.IEntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.flashbang.AppMode;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.GameObjectRef;
import com.threerings.flashbang.debug.Profiler;
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

    public function addSingletonComponent (comp :IEntityComponent, compName :String)
        :IEntity
    {
        log.info("addSingletonComponent", "comp", comp);
		
		var obj :GameObjectEntity = new GameObjectEntity(compName);
		obj.addComponent(comp, compName);
		addObject(obj);
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

    override public function update (dt :Number) :void
    {
        _elapsedTime += dt;
        super.update(dt);
    }

    /** Elapsed time for this ObjectDB */
    protected var _elapsedTime :Number = 0;
	protected var _tempPropertyInfo :PropertyInfo = new PropertyInfo();

    protected static const log :Log = Log.getLog(EntityAppmode);
}
}