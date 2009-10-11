package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;

import flash.display.Graphics;
import flash.geom.Point;

import libdamago.geometry.Polygon;

/**
 * The trapezoid must be wider at the base than at the top.
 */
public class BoundsTrapezoid extends BoundsPolygon
{
    public function BoundsTrapezoid (x :Number, y :Number, topWidth :Number, bottomWidth :Number,
        height :Number)
    {
        var bottomExtension :Number = (bottomWidth - topWidth) / 2;
        _topLeft = new Vector2(x, y);
        _topRight = new Vector2(x + topWidth, y);
        _bottomRight = new Vector2(x + topWidth + bottomExtension, y + height);
        _bottomLeft = new Vector2(x - bottomExtension, y + height);
        super(new Polygon([_topLeft, _topRight, _bottomRight, _bottomLeft]));
    }

    override public function getBoundedPoint (targetX :Number, targetY :Number) :Point
    {
        var finalX :Number = targetX;
        var finalY :Number = targetY;
        //y coord is easy
        finalY = MathUtil.clamp(targetY, _topLeft.y, _bottomLeft.y);

        //If d is within the square bounded by the parallelogram, no further x checking is needed
        var minX :Number = Math.max(_topLeft.x, _bottomLeft.x);
        var maxX :Number = Math.min(_topRight.x, _bottomRight.x);
        if (targetX >= minX && targetX <= maxX) {
            return new Point(targetX, finalY);
        }

        //Check for intersections
        return super.getBoundedPoint(targetX, targetY);
    }

    protected var _topLeft :Vector2;
    protected var _topRight :Vector2;
    protected var _bottomRight :Vector2;
    protected var _bottomLeft :Vector2;
}
}
