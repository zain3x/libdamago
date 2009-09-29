package com.threerings.ui {
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.contrib.EventHandlerManager;

import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;


public class DropdownMenu extends Sprite
{
    public function DropdownMenu (itemLabels :Array, items :Array, onItemSelected :Function,
        maxRows :int = 30)
    {
        _items = items != null ? items : [];
        _itemLabels = itemLabels;
        _onItemSelected = onItemSelected;

        var yOffset :Number = 0;
        var xOffset :Number = 0;
        for (var ii :int = 0; ii < itemLabels.length; ++ii) {
            var name :String = itemLabels[ii];
            var value :* = items[ii];

            var selectButton :Sprite = new Sprite();
            selectButton.addChild(TextBits.createText(name, 1, 0, 0, "left"));
            _events.registerListener(selectButton, MouseEvent.CLICK,
                createItemSelectedCallback(ii));

            var g :Graphics = selectButton.graphics;
            g.beginFill(0xffffff);
            g.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
            g.endFill();
            _events.registerListener(selectButton, MouseEvent.ROLL_OVER,
                createMouseOverCallback(selectButton));
            _events.registerListener(selectButton, MouseEvent.ROLL_OUT,
                createMouseOutCallback(selectButton));

            selectButton.y = (selectButton.height * 0.5) + yOffset;
            selectButton.x = xOffset;
            addChild(selectButton);

            yOffset += selectButton.height;
            if (ii != 0 && ii % maxRows == 0) {
                xOffset += BUTTON_WIDTH;
                yOffset = 0;
            }
        }

        _events.registerListener(this, MouseEvent.ROLL_OUT, Util.adapt(shutdown));
    }

    protected function createMouseOverCallback (s :Sprite) :Function
    {
        var g :Graphics = s.graphics;
        return function () :void {
            g.beginFill(0xffff00);
            g.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
            g.endFill();
        };
    }

    protected function createMouseOutCallback (s :Sprite) :Function
    {
        var g :Graphics = s.graphics;
        return function () :void {
            g.beginFill(0xffffff);
            g.drawRect(0, 0, BUTTON_WIDTH, BUTTON_HEIGHT);
            g.endFill();
        };
    }

    protected function selectItem (idx :int) :void
    {
        if (idx < _items.length) {
            _onItemSelected(_items[idx]);
        } else {
            _onItemSelected(_itemLabels[idx]);
        }
    }

    protected function createItemSelectedCallback (idx :int) :Function
    {
        return function (...ignored) :void {
            selectItem(idx);
            shutdown();
        };
    }

    public function shutdown () :void
    {
        DisplayUtils.detach(this);
        _events.freeAllHandlers();
    }

    protected var _button :SimpleButton;
    protected var _items :Array;
    protected var _itemLabels :Array;
    protected var _onItemSelected :Function;
    protected var _events :EventHandlerManager = new EventHandlerManager();

    protected static const log :Log = Log.getLog(DropdownMenu);

    protected static const BUTTON_HEIGHT :int = 20;
    protected static const BUTTON_WIDTH :int = 200;
}

}

