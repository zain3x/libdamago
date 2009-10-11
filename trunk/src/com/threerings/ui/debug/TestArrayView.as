package com.threerings.ui.debug
{
import com.threerings.display.DisplayUtil;
import com.threerings.text.TextFieldUtil;
import com.threerings.ui.OrientationType;
import com.threerings.ui.SimpleScrollableArrayView;
import libdamago.util.DebugUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class TestArrayView extends Sprite
{
    public function TestArrayView ()
    {
        var arrayview :SimpleScrollableArrayView = new SimpleScrollableArrayView(
            OrientationType.HORIZONTAL, 300, 50);
        addChild(arrayview);
        arrayview.x = 300;
        arrayview.y = 200;

        for (var ii :int = 0; ii < 12; ++ii) {
            arrayview.add(createBlob(ii));
        }
    }

    protected static function createBlob (idx :int) :DisplayObject
    {
        var size :Number = 16;
        var s :Sprite = new Sprite();
        DebugUtil.fillDot(s, 0xffffff, size, size/2, size/2);
        var tf :TextField = TextFieldUtil.createField(idx + "", {textColor:0, autoSize:TextFieldAutoSize.LEFT});
        s.addChild(tf);
        DisplayUtil.positionBounds(tf, 0, 0);
        DebugUtil.drawRect(s, s.width, s.height);
        return s;
    }

}
}
