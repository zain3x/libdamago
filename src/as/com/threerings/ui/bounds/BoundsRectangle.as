package com.threerings.ui.bounds {
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;

import flash.geom.Rectangle;

import net.amago.math.geometry.Polygon;

public class BoundsRectangle extends BoundsPolygon
{
    public static function fromRectangle (rect :Rectangle) :BoundsRectangle
    {
        return new BoundsRectangle(rect.x, rect.y, rect.width, rect.height);
    }

    public function BoundsRectangle (x :Number, y :Number, w :Number, h :Number)
    {
        _rect = new Rectangle(x, y, w, h);
        super(new Polygon([ new Vector2(_rect.left, _rect.top), new Vector2(_rect.right, _rect.top),
            new Vector2(_rect.right, _rect.bottom), new Vector2(_rect.left, _rect.bottom)]));
    }

    override public function toString () :String
    {
        return ClassUtil.tinyClassName(BoundsRectangle) + "[" + _rect + "]";
    }

    protected var _rect :Rectangle;
}
}
