package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.IEntity;
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import com.threerings.util.ClassUtil;
//This is more of a hassle than it's worth, will remove in the future.
public class SceneComponent extends EntityComponent
{
    public static const CHANGED :String = COMPONENT_NAME + "Changed";
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SceneComponent);

    public static function getDisplayObjectFrom (e :IEntity) :DisplayObject
    {
        return (e.lookupComponentByName(COMPONENT_NAME) as SceneComponent)._displayObject;
    }

    public static function getFrom (e :IEntity) :SceneComponent
    {
        return e.lookupComponentByName(COMPONENT_NAME) as SceneComponent;
    }

    public static function getSpriteFrom (e :IEntity) :Sprite
    {
        return (e.lookupComponentByName(COMPONENT_NAME) as SceneComponent)._displayObject as Sprite;
    }

    public function SceneComponent (disp :DisplayObject = null)
    {
        _displayObject = disp;
    }

    public function get displayObject () :DisplayObject
    {
        return _displayObject;
    }

    public function changed () :void
    {
        owner.eventDispatcher.dispatchEvent(_event);
    }

    protected var _displayObject :DisplayObject;
    protected var _event :Event = new Event(CHANGED);
}
}