package net.amago.util {
import com.pblabs.engine.entity.IEntityComponent;
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
     * Get the next available object from the pool, or create a new object if pool is emtpy.
     */
    public function getNewObject (clazz :Class) :*
    {
        Preconditions.checkNotNull(clazz);
        var pool :ObjectPool = _pools.get(clazz) as ObjectPool;
        if (pool != null) {
            return pool.getObject();
        } else {
            log.debug("getObject, class not registered ", clazz);
            log.debug("registered classes:", _classes);
            return new clazz();
        }
    }

    public function register (clazz :Class, pool :ObjectPool = null) :void
    {
        Preconditions.checkArgument(_pools.get(clazz) == null, clazz + " already registered");
        if (pool == null) {
            pool = new ObjectPool(clazz);
        }
        _pools.put(clazz, pool);
        _classes.push(clazz);
    }

    public function shutdown () :void
    {
        _pools.forEach(function (clazz :Class, pool :ObjectPool) :void {
                pool.shutdown();
            });
        _pools.clear();
        _classes = null;
    }

    protected var _classes :Array = []; //<type:Class>
    protected var _pools :Map = Maps.newMapOf(Class); //<type:Class, ObjectPool>

    protected static const log :Log = Log.getLog(ObjectPoolMgr);
}
}