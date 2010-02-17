//
// $Id$

package com.threerings.flashbang.objects {

import com.threerings.util.DisplayUtils;
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.components.SceneComponent;


/**
 * A SceneObject with children GameObjects.  The children use the db, but are destroyed
 * with the parent.
 */
public class SceneObjectParent extends SceneObject
{
    override protected function addedToDB () :void
    {
        super.addedToDB();
        for each (var sim :GameObject in _yetToAddToDB) {
            if (sim.db == null) {
                db.addObject(sim);
            }
        }
        _yetToAddToDB = null;
    }

    protected function addGameObjectInternal (s :GameObject) :void
    {
        if (db != null) {
            if (s.db == null) {
                db.addObject(s);
            }

        } else {
            _yetToAddToDB.push(s);
        }

        if (!ArrayUtil.contains(_subObjects, s)) {
            _subObjects.push(s);
        }
    }

    public function addSceneObject (obj :GameObject,
        displayParent :DisplayObjectContainer = null) :void
    {
        if (obj is SceneComponent) {
            // Attach the object to a display parent.
            var disp :DisplayObject = (obj as SceneComponent).displayObject;
            if (null == disp) {
                throw new Error("obj must return a non-null displayObject to be attached " +
                                "to a display parent");
            }

            if (displayParent == null) {
                displayParent = _displaySprite;
            }
            displayParent.addChild(disp);
        }
        addGameObjectInternal(obj);
    }

    public function addGameObject (obj :GameObject) :void
    {
        addGameObjectInternal(obj);
    }

    protected function destroyGameObject (s :GameObject) :void
    {
        if (s == null) {
            return;
        }

        if (s.isLiveObject) {
            s.destroySelf();

        } else if (s is SceneObject) {
            DisplayUtils.detach(SceneObject(s).displayObject);
        }

        ArrayUtil.removeAll(_subObjects, s);
    }

    override protected function destroyed () :void
    {
        super.destroyed();
        for each (var child :GameObject in _subObjects) {
            if (child.isLiveObject) {
                child.destroySelf();
            }
        }
    }


    protected function destroyChildren () :void
    {
        for each (var child :GameObject in _subObjects) {
            if (child.isLiveObject) {
                child.destroySelf();
            }
        }
        _subObjects = [];
    }

    override public function get displayObject () :DisplayObject
    {
        return _displaySprite;
    }

    protected var _displaySprite :Sprite = new Sprite();
    protected var _subObjects :Array = new Array();
    protected var _yetToAddToDB :Array = new Array();
}
}
