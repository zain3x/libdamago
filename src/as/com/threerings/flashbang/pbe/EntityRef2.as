package com.threerings.flashbang.pushbutton {
public class EntityRef2
{
    public static function Null () :EntityRef2
    {
        return g_null;
    }
    
    public function destroyObject () :void
    {
        if (null != _obj) {
            _obj.destroySelf();
        }
    }
    
    public function get object () :PBEObject
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
    
    protected static var g_null :EntityRef2 = new EntityRef2();
    
    // managed by ObjectDB
    internal var _obj :PBEObject;
    internal var _next :EntityRef2;
    internal var _prev :EntityRef2;
}
}