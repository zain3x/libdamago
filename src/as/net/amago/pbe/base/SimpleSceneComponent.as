package net.amago.pbe.base {
import com.pblabs.engine.entity.IEntity;
import com.threerings.display.DisplayUtil;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
/**
 * SceneComponent containing a sprite, and detaches when destroyed.
 */
public class SimpleSceneComponent extends SceneComponent
{
    public static const COMPONENT_NAME :String = ClassUtil.tinyClassName(SimpleSceneComponent);

    public static function getFrom (e :IEntity) :SimpleSceneComponent
    {
        return e.lookupComponentByName(COMPONENT_NAME) as SimpleSceneComponent;
    }

    public static function getSpriteFrom (e :IEntity) :Sprite
    {
        var sc :SimpleSceneComponent = SimpleSceneComponent.getFrom(e);
        return sc != null ? sc.displayObject as Sprite : null;
    }

    public static function getDisplayObjectFrom (e :IEntity) :DisplayObject
    {
        var sc :SimpleSceneComponent = getFrom(e);
        return sc != null ? sc.displayObject : null;
    }

    public function SimpleSceneComponent ()
    {
        super(new Sprite());
    }

    public function get sprite () :Sprite
    {
        return _displayObject as Sprite;
    }

    override protected function onRemove():void
    {
        DisplayUtil.detach(_displayObject);
        super.onRemove();
    }
}
}