package com.threerings.flashbang.pushbutton.scene {
import com.threerings.ui.DisplayUtils;
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

    public function get scene () :Scene
    {
        return _parentScene;
    }
    public function addObject (obj :*, disp :DisplayObject = null) :void
    {
        if (null != _parentScene) {
            throw new Error("If this layer is attached to a Scene, use Scene.addSceneComponent");
        } else {
            addObjectInternal(obj, disp);
        }
    }

    public function containsObject (obj :*) :Boolean
    {
        return _sceneComponents.containsKey(obj);
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

    public function removeObject (obj :*) :void
    {
        if (null != _parentScene) {
            throw new Error("If this layer is attached to a Scene, use Scene.removeSceneComponent");
        } else {
            removeObjectInternal(obj);
        }
    }

    //Override to do something fancy e.g. parallax, or iso sorting
    public function render (...ignored) :void
    {

    }

    public function clear () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }
        _sceneComponents.clear();
    }


    internal function addObjectInternal (obj :*, disp :DisplayObject = null) :void
    {
        if (_sceneComponents.containsKey(obj)) {
            throw new Error("Already contains obj " + obj);
        }

        if (null == disp) {
            if (!(obj is DisplayObject)) {
                throw new Error("If the first arg is not a DisplayObject, you must " +
                        "supply a DisplayObject as the second argument");
            } else {
                disp = obj as DisplayObject;
            }
        }

        _sceneComponents.put(obj, disp);
        addChild(disp);
        dirty = true;
        objectAdded(obj);
    }

    //Subclasses override
    protected function objectRemoved (obj :*) :void
    {

    }

    //Subclasses override
    protected function objectAdded (obj :*) :void
    {

    }

    //Subclasses override
    protected function attached () :void
    {

    }

    internal function attachedInternal () :void
    {
        attached();
    }

    //Subclasses override
    protected function detached () :void
    {

    }

    internal function detachedInternal () :void
    {
        while (numChildren > 0) {
            removeChildAt(0);
        }
        detached();
    }

    internal function removeObjectInternal (obj :*) :void
    {
        if (!_sceneComponents.containsKey(obj)) {
//            throw new Error("Doesn't contain " + obj);
            log.error("Doesn't contain " + obj);
            return;
        }
        var disp :DisplayObject = _sceneComponents.get(obj) as DisplayObject;
        _sceneComponents.remove(obj);
        DisplayUtils.detach(disp);
//        removeChild(disp);
        dirty = true;
        objectRemoved(obj);
    }

    internal function renderInternal () :void
    {
        render();
    }

    /** We'll accept any kind of object mapped to a DisplayObject*/
    protected var _sceneComponents :Map = Maps.newMapOf(Object);

    internal var _parentScene :Scene;

    protected static const log :Log = Log.getLog(SceneLayer);
}
}