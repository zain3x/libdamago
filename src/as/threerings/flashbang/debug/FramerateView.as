//
// $Id$

package com.threerings.flashbang.debug {

import com.threerings.flashbang.objects.SceneObject;
import com.threerings.ui.TextBits;
import com.threerings.util.Framerate;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;

public class FramerateView extends SceneObject
{
    public function FramerateView ()
    {
        _sprite = new Sprite();

        _framerate = new Framerate(_sprite, 1000);

        _tf = new TextField();
        _sprite.addChild(_tf);
    }

    override protected function destroyed () :void
    {
        _framerate.shutdown();
    }

    override protected function update (dt :Number) :void
    {
        var text :String =
            "" + Math.round(_framerate.fpsCur) +
            " (Avg=" + Math.round(_framerate.fpsMean) +
            " Min=" + Math.round(_framerate.fpsMin) +
            " Max=" + Math.round(_framerate.fpsMax) + ")";

        var color :uint = (_framerate.fpsMean > SLOW_FPS ? 0x00ff00 : 0xff0000);

        TextBits.initTextField(_tf, text, 1.1, 0, color);
    }

    override public function get displayObject () :DisplayObject
    {
        return _sprite;
    }

    protected var _sprite :Sprite;
    protected var _tf :TextField;
    protected var _framerate :Framerate;

    protected static const SLOW_FPS :Number = 15;
}

}
