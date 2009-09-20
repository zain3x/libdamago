package com.threerings.ui
{
import aduros.util.F;

import com.whirled.contrib.EventHandlerManager;
import com.whirled.contrib.SpriteUtil;
import com.whirled.contrib.debug.DebugUtil;

import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.events.MouseEvent;

public class SimpleButtonPanel extends ArrayView
{
    public function SimpleButtonPanel (type :OrientationType, parent :DisplayObjectContainer = null,
        locX :Number = 0, locY :Number = 0)
    {
        super(type);
        if (parent != null) {
            parent.addChild(this);
        }
        this.x = locX;
        this.y = locY;
    }

    public function createAndAddButton (name :String, onClick :Function) :SimpleTextButton
    {
        var b :SimpleTextButton = new SimpleTextButton(name);
        _events.registerListener(b, MouseEvent.CLICK, F.adapt(onClick));
        super.add(b);
        return b;
    }

    public function createAndAddMouseDownButton (name :String, onMouseDown :Function) :Sprite
    {
        var b :Sprite = SpriteUtil.createSprite(true, true);

        DebugUtil.fillRect(b, 50, 30, 0xffffff, 0);
        var g :Graphics = b.graphics;
        g.lineStyle(0,0,0);
        g.beginFill(0xffffff, 1);
        g.drawRect(5, 5, 40, 20);
        g.endFill();

        b.addChild(TextBits.createText(name));
        _events.registerListener(b, MouseEvent.MOUSE_DOWN, F.adapt(onMouseDown));
        super.add(b);
        return b;
    }

    public function shutdown () :void
    {
        _events.freeAllHandlers();
        _elements = null;
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();

}
}