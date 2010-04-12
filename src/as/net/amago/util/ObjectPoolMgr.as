package net.amago.util {
import com.pblabs.engine.entity.IEntityComponent;
import com.threerings.downtown.scene.GlobalLocationComponent;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Preconditions;

public class ObjectPoolMgr
{

    public function get registeredClasses () :Array
    {
        return _classes;
    }

    public function addObject (o :*) :void
    {
        if (o == null) {
            log.debug("addObject", "object", null);
            return;
        }
        var pool :ObjectPool = _pools.get(ClassUtil.getClass(o)) as ObjectPool;
        if (pool == null) {
            log.debug("addObject, class not registered", o);
            return;
        }
        pool.addObject(o);
    }

    /**
     * Get the next available object from the pool or put it back for the
     * next use. If the pool is empty and resizable, an error is thrown.
     */
    public function getNewObject (clazz :Class) :*
    {
        Preconditions.checkNotNull(clazz);
        var pool :ObjectPool = _pools.get(clazz) as ObjectPool;
        var obj :Object;
        if (pool != null && pool.size > 0) {
            obj = pool.getObject();
        }
        if (obj == null) {
            log.debug("getObject, class not registered ", clazz);
            log.debug("registered classes:", _classes);
            if (pool != null) {
                //trace("Creating from scratch", clazz);
            }
            obj = new clazz();
        }
        return obj;
    }
    public function register (clazz :Class, pool :ObjectPool = null) :void
    {
        Preconditions.checkArgument(_pools.get(clazz) == null, clazz + " already registered");
        if (pool == null && _defaultPools.containsKey(clazz)) {
            var poolClazz :Class = _defaultPools.get(clazz) as Class;
            pool = new poolClazz() as ObjectPool;
        }
        if (pool == null) {
            pool = new ObjectPool(clazz);
        }
        _pools.put(clazz, pool);
        _classes.push(clazz);
    }

    protected var _classes :Array = []; //<type:Class>

    protected var _pools :Map = Maps.newMapOf(Class); //<type:Class, ObjectPool>

    protected static var _defaultPools :Map = Maps.newMapOf(Class);//<type:Class, ObjectPool type :Class>
    _defaultPools.put(IEntityComponent, PoolEntityComponent);

    protected static const log :Log = Log.getLog(ObjectPoolMgr);
}
}