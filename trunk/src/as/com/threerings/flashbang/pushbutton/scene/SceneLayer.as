package com.threerings.flashbang.pushbutton.scene {
import com.threerings.util.ArrayUtil;
import com.threerings.util.DisplayUtils;
import com.threerings.util.Log;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.display.DisplayObject;
import flash.display.Sprite;

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
    protected function objectAdded (obj :SceneEntityComponent) :void
    {
        addChild(obj.displayObject);
    }

    //Subclasses override
    protected function objectRemoved (obj :SceneEntityComponent) :void
    {
        if (obj.displayObject != null && contains(obj.displayObject)) {
            removeChild(obj.displayObject);
        }
    }

    internal function addObjectInternal (obj :SceneEntityComponent) :void
    {
        if (ArrayUtil.contains(_sceneComponents, obj)) {
            throw new Error("Already contains obj " + obj);
        }

        _sceneComponents.push(obj);
        dirty = true;
        objectAdded(obj);
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

        for each (var obj :SceneEntityComponent in _sceneComponents.concat()) {
            removeObjectInternal(obj);
        }

        detached();
    }

    internal function removeObjectInternal (obj :SceneEntityComponent) :void
    {
        if (!ArrayUtil.contains(_sceneComponents, obj)) {
            log.error("Doesn't contain " + obj);
            return;
        }
        ArrayUtil.removeFirst(_sceneComponents, obj);
        dirty = true;
        objectRemoved(obj);
    }

    internal function renderInternal () :void
    {
        render();
    }

    protected var _sceneComponents :Array = [];
    internal var _parentScene :Scene2DComponent;

    protected static const log :Log = Log.getLog(SceneLayer);
}
}