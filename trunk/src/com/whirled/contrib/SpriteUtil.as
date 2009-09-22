//
// $Id: SpriteUtil.as 4934 2009-09-04 17:47:44Z tim $

package com.whirled.contrib{

import com.whirled.contrib.debug.DebugUtil;

import flash.display.Sprite;

public class SpriteUtil
{
    public static function createSprite (mouseChildren :Boolean = false,
        mouseEnabled :Boolean = false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }

    public static function createFilledSprite (w :Number, h :Number, color :uint, alpha :Number,
        mouseChildren :Boolean = false, mouseEnabled :Boolean = false) :Sprite
    {
        var sprite :Sprite = new Sprite();
        DebugUtil.fillRect(sprite, w, h, color);
        sprite.mouseChildren = mouseChildren;
        sprite.mouseEnabled = mouseEnabled;
        return sprite;
    }
}

}
