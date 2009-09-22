package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;

import flash.geom.Point;
import flash.geom.Rectangle;

import libdamago.geometry.Polygon;

public class BoundsRectangle extends BoundsPolygon
{
    public static function fromRectangle (rect :Rectangle) :BoundsRectangle
    {
        return new BoundsRectangle(rect.x, rect.y, rect.width, rect.height);
    }

    public function BoundsRectangle (x :Number, y :Number, w :Number, h :Number)
    {
        _rect = new Rectangle(x, y, w, h);
        super(new Polygon([new Vector2(_rect.left, _rect.top), new Vector2(_rect.right, _rect.top),
            new Vector2(_rect.right, _rect.bottom), new Vector2(_rect.left, _rect.bottom)]));
    }

    override public function getBoundedPoint (x :Number, y :Number) :Point
    {
        return new Point(MathUtil.clamp(x, _rect.left, _rect.right),
            MathUtil.clamp(y, _rect.top, _rect.bottom));
    }

    protected var _rect :Rectangle;
}
}