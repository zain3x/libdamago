package com.threerings.flashbang.pushbutton {
import com.pblabs.engine.entity.IEntity;

public class EntityRef
{
    public static function Null () :EntityRef
    {
        return g_null;
    }
    
    public function destroyObject () :void
    {
        if (null != _obj) {
            _obj.destroy();
        }
    }
    
    public function get object () :EntityObject
    {
        return _obj;
    }
    
    public function get isLive () :Boolean
    {
        return (null != _obj);
    }
    
    public function get isNull () :Boolean
    {
        return (null == _obj);
    }
    
    protected static var g_null :EntityRef = new EntityRef();
    
    // managed by ObjectDB
    internal var _obj :EntityObject;
    internal var _next :EntityRef;
    internal var _prev :EntityRef;
}
}