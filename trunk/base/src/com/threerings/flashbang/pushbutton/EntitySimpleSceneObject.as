package com.threerings.flashbang.pushbutton {
import com.threerings.flashbang.objects.EntitySceneComponent;
public class EntitySimpleSceneObject extends EntitySceneComponent
{
    public function EntitySimpleSceneObject (displayObject :DisplayObject = null, name :String = null)
    {
        _displayObject = displayObject;
        super(name);
    }

    override public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    public function set displayObject (displayObject :DisplayObject) :void
    {
        _displayObject = displayObject;
    }

    protected var _displayObject :DisplayObject;
    protected var _name :String;
}
}