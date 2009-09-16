//
// $Id: SpriteUtil.as 4934 2009-09-04 17:47:44Z tim $

package com.whirled.contrib{

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
}

}
