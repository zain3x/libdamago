package com.threerings.flashbang.pushbutton.scene {
import flash.display.DisplayObject;
import flash.display.Sprite;
import com.threerings.util.DisplayUtils;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

/**
 * Can be used independently or in conjunction with a Scene + SceneView.
 *
 * If used without a Scene, render should be called on Event.ENTER_FRAME.
 */
public class SceneLayer extends Sprite
{
    public var dirty :Boolean;

    public function SceneLayer ()
    {
        super();
    }

    public function get scene () :Scene2DComponent
    {
        return _parentScene;
    }

    public function clear () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }
        _sceneComponents.clear();
    }

    public function detach () :void
    {
        if (null != _parentScene) {
            _parentScene.removeLayer(this);
        } else if (parent != null) {
            parent.removeChild(this);
            detachedInternal();
        }
    }

    //Override to do something fancy e.g. parallax, or iso sorting
    public function render (... ignored) :void
    {

    }

    //Subclasses override
    protected function attached () :void
    {

    }

    //Subclasses override
    protected function detached () :void
    {

    }

    //Subclasses override
    protected function objectAdded (obj :SceneEntityComponent, disp :DisplayObject) :void
    {

    }

    //Subclasses override
    protected function objectRemoved (obj :SceneEntityComponent, disp :DisplayObject) :void
    {

    }

    internal function addObjectInternal (obj :SceneEntityComponent) :void
    {
        if (_sceneComponents.containsKey(obj)) {
            throw new Error("Already contains obj " + obj);
        }

        _sceneComponents.put(obj, obj.displayObject);
        addChild(obj.displayObject);
        dirty = true;
        objectAdded(obj, obj.displayObject);
    }

    internal function attachedInternal () :void
    {
        attached();
    }

    internal function detachedInternal () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }
        detached();
    }

    internal function removeObjectInternal (obj :SceneEntityComponent) :void
    {
        if (!_sceneComponents.containsKey(obj)) {
            log.error("Doesn't contain " + obj);
            return;
        }
        var disp :DisplayObject = _sceneComponents.get(obj) as DisplayObject;
        _sceneComponents.remove(obj);
        DisplayUtils.detach(disp);
        dirty = true;
        objectRemoved(obj, disp);
    }

    internal function renderInternal () :void
    {
        render();
    }

    /** We'll accept any kind of object mapped to a DisplayObject*/
    protected var _sceneComponents :Map = Maps.newMapOf(Object);

    internal var _parentScene :Scene2DComponent;

    protected static const log :Log = Log.getLog(SceneLayer);
}
}