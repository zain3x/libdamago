package net.amago.util {
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.Preconditions;

public class ObjectPool
{
    /**
     * Creates a new object pool.
     *
     * @param grow If true, the pool grows the first time it becomes empty.
     */
    public function ObjectPool (clazz :Class)
    {
        Preconditions.checkNotNull(clazz, "You must supply a class argument");
        _clazz = clazz;
        _objects = [];
    }

    public function get clazz () :Class
    {
        return _clazz;
    }

    /**
     * The pool size.
     */
    public function get size () :int
    {
        return _objects.length;
    }

    /**
     * @private
     */
    public function addObject (o :*) :void
    {
        Preconditions.checkArgument((o is _clazz), "Object added must by of type " + _clazz);
        _objects.push(o);
    }

    /**
     * Get the next available object from the pool or put it back for the
     * next use. If the pool is empty and resizable, an error is thrown.
     */
    public function getObject () :*
    {
        var obj :* = _objects.shift();
        if (obj == null) {
            obj = new clazz();
            log.debug("no objects in pool, creating", _clazz);
            return obj;
        } else {
            log.debug("from pool", _clazz);
            return obj;
        }
    }

    /**
     * Unlock all ressources for the garbage collector.
     */
    public function shutdown () :void
    {
        _objects = null;
    }

    protected var _clazz :Class;
    protected var _objects :Array = [];

    protected static const log :Log = Log.getLog(ObjectPool);
}
}

