//
// $Id$

package com.threerings.util {
import flash.display.Sprite;
import com.threerings.util.DebugUtil;
public class SpriteUtil
{

    public static function createFilledSprite (w :Number, h :Number, color :uint = 0,
        alpha :Number = 1, mouseChildren :Boolean = false, mouseEnabled :Boolean = false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        DebugUtil.fillRect(sprite, w, h, color);
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }
    public static function createSprite (mouseChildren :Boolean = false, mouseEnabled :Boolean =
        false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }
}

}
