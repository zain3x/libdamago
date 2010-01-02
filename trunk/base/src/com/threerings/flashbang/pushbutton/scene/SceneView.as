/*******************************************************************************
 * PushButton Engine
 * Copyright (C) 2009 PushButton Labs, LLC
 * For more information see http://www.pushbuttonengine.com
 *
 * This file is licensed under the terms of the MIT license, which is included
 * in the License.html file at the root directory of this SDK.
 ******************************************************************************/
package com.threerings.flashbang.pushbutton.scene {
import com.threerings.util.DebugUtil;

import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.Event;
/**
 * This class can be set as the SceneView on the BaseSceneComponent class and is used
 * as the canvas to draw the objects that make up the scene. It defaults to the size
 * of the stage.
 *
 * <p>Currently this is just a stub, and exists for clarity and potential expandability in
 * the future.</p>
 */
public class SceneView extends Sprite
{
    public static const NAME :String = "SceneView";

    public function SceneView (width :Number = 0, height :Number = 0)
    {
        name = NAME;

        if (width <= 0 || height <= 0) {
            addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        } else {
            this.width = width;
            this.height = height;
        }
    }

    protected function handleAddedToStage (...ignored) :void
    {
        removeEventListener(Event.ADDED_TO_STAGE, handleAddedToStage);
        // Intelligent default size.
        width = stage.stageWidth;
        height = stage.stageHeight;
    }

    override public function get height () :Number
    {
        return _height;
    }

    override public function set height (value :Number) :void
    {
        _height = value;
        debugDrawBounds();
    }

    override public function get width () :Number
    {
        return _width;
    }

    override public function set width (value :Number) :void
    {
        _width = value;
        debugDrawBounds();
    }

    public function addDisplayObject (dobj :DisplayObject) :void
    {
        addChild(dobj);
    }

    public function clearDisplayObjects () :void
    {
        while (numChildren) {
            removeChildAt(0);
        }
    }

    protected function debugDrawBounds () :void
    {
        var g :Graphics = graphics;
        g.clear();
        g.lineStyle(1, 1);
        DebugUtil.fillRect(this, _width, _height, 0xffffff, 1);
        DebugUtil.drawRect(this, _width, _height, 0xff0000);
    }

    public function removeDisplayObject (dObj :DisplayObject) :void
    {
        removeChild(dObj);
    }

    public function setDisplayObjectIndex (dObj :DisplayObject, index :int) :void
    {
        setChildIndex(dObj, index);
    }

    public function set debug (val :Boolean) : void
    {
        _debug = val;
        var g :Graphics = this.graphics;
        g.clear();
        if (_debug) {
            DebugUtil.drawRect(this, _width, _height, 0);
        }
    }

    public function get debug () :Boolean
    {
        return _debug;
    }

    protected var _height :Number = 0;
    protected var _width :Number = 0;
    protected var _debug :Boolean;

}
}
