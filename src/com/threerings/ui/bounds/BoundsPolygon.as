package com.threerings.ui.bounds
{
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;

import flash.display.Graphics;
import flash.geom.Point;
import flash.geom.Rectangle;

import libdamago.geometry.Polygon;

public class BoundsPolygon extends Bounds
{
    public function BoundsPolygon (polygon :Polygon)
    {
        _polygon = polygon;
    }

    override public function getBoundedPoint (targetX :Number, targetY :Number) :Point
    {
        if (_polygon.isPointInside(new Vector2(targetX, targetY))) {
            return new Point(targetX, targetY);
        }

        var closestPoint :Vector2 = _polygon.closestPointOnPerimeter(
            new Vector2(targetX, targetY));
        return closestPoint.toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number, targetX :Number,
        targetY :Number) :Point
    {
        var polygonBounds :Rectangle = _polygon.boundingBox;
        //Correct for intersections due to already being on the perimeter.
        originY = MathUtil.clamp(originY, polygonBounds.top + 1, polygonBounds.bottom - 1);
        if (_polygon.isPointInside(new Vector2(targetX, targetY))) {
            return new Point(targetX, targetY);
        }

        var points :Array = _polygon.getIntersectionPoints(new Vector2(originX, originY),
            new Vector2(targetX, targetY));
        if (points.length == 0) {
            var closestPoint :Vector2 = _polygon.closestPointOnPerimeter(
                new Vector2(targetX, targetY));
            return closestPoint.toPoint();
        }

        return Vector2(points[0]).toPoint();
    }

    override public function debugDraw (g :Graphics) :void
    {
        g.lineStyle(2, 0xff0000);
        var points :Array = _polygon.vertices.slice();
        points.push(_polygon.vertices[0]);
        for (var ii :int = 0; ii < points.length - 1; ++ii) {
            var p1 :Vector2 = points[ii] as Vector2;
            var p2 :Vector2 = points[ii + 1] as Vector2;
            g.moveTo(p1.x, p1.y);
            g.lineTo(p2.x, p2.y);
        }
    }

    override public function distance (p :Point) :Number
    {
        return _polygon.distToPolygonEdge(Vector2.fromPoint(p));
    }

    override public function get width () :Number
    {
        return _polygon.boundingBox.width;
    }
    override public function get height () :Number
    {
        return _polygon.boundingBox.height;
    }

    protected var _polygon :Polygon;
}
}