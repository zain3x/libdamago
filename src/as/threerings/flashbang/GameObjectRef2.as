package com.threerings.flashbang {
public class GameObjectRef2
{
	public static function Null () :GameObjectRef2
	{
		return g_null;
	}
	
	public function destroyObject () :void
	{
		if (null != _obj) {
			_obj.destroySelf();
		}
	}
	
	public function get object () :GameObject2
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
	
	protected static var g_null :GameObjectRef2 = new GameObjectRef2();
	
	// managed by ObjectDB
	internal var _obj :GameObject2;
	internal var _next :GameObjectRef2;
	internal var _prev :GameObjectRef2;
}
}