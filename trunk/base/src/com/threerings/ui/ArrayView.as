package com.threerings.ui
{
import com.threerings.display.DisplayUtil;
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;

public class ArrayView extends Sprite
{
    public static const VERTICAL :String = "VERTICAL";
    public static const HORIZONTAL :String = "HORIZONTAL";

    public function ArrayView (type :OrientationType)
    {
        if (type == null) {
            throw new Error("type must be VERTICAL or HORIZONTAL");
        }
        _type = type;
    }

    public function add (d :DisplayObject) :void
    {
        _elements.push(d);
        redrawElements();
    }

    public function remove (d :DisplayObject) :void
    {
        ArrayUtil.removeAll(_elements, d);
        redrawElements();
    }

    public function redrawElements () :void
    {
        var idx :int;
        var obj :DisplayObject;
        var loc :Point;
        var spaceTakenByPreviousElements :int = 0;
        var posX :Number;
        var posY :Number;
        for (idx = 0; idx < _elements.length; ++idx) {
            obj = _elements[idx] as DisplayObject;
            posX = (_type == OrientationType.HORIZONTAL ? spaceTakenByPreviousElements : 0);
            posY = (_type == OrientationType.HORIZONTAL ? 0 : spaceTakenByPreviousElements);
            DisplayUtil.positionBounds(obj, posX, posY);

            if (obj.parent != this) {
                this.addChild(obj);
            }
            spaceTakenByPreviousElements += (_type == OrientationType.HORIZONTAL ? obj.width : obj.height);
        }
    }

    protected static function setTopLeft (d :DisplayObject, left :int, top :int) :void
    {

    }

    public function shutdown () :void
    {
        DisplayUtils.removeAllChildren(this);
        _elements.splice(0);
    }

    protected var _type :OrientationType;
    protected var _elements :Array = [];
}
}
