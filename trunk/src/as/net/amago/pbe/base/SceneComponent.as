package net.amago.pbe.base {
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.IEntity;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
//This is more of a hassle than it's worth, will remove in the future.
public class SceneComponent extends EntityComponent
{
    public static const CHANGED :String = COMPONENT_NAME + "Changed";
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SceneComponent);

    public static function getDisplayObjectFrom (e :IEntity) :DisplayObject
    {
        var sc :SceneComponent = getFrom(e);
        return sc != null ? sc.displayObject : null;
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

//    public function set displayObject (disp :DisplayObject) :void
//    {
//        //Only allow setting the display when not attached to an IEntity.
//        if (owner == null) {
//            _displayObject = disp;
//        } else {
//            log.error("Cannot set displayObject after IEntity owner is initialized");
//        }
//    }

    override protected function onRemove():void
    {
        super.onRemove();
        _displayObject = null;
    }

    protected var _displayObject :DisplayObject;

    /**
     * For use with non-event-cloning IEventDispatchers.
     */
    protected static const _event :Event = new Event(CHANGED);
    protected static const log :Log = Log.getLog(SceneComponent);
}
}