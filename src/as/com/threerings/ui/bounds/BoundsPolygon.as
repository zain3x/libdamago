package com.threerings.ui.bounds {
import flash.display.DisplayObject;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.geom.Vector2;
import com.threerings.util.ClassUtil;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;
import net.amago.math.geometry.LineSegment;
import net.amago.math.geometry.Polygon;

public class BoundsPolygon extends Bounds
{
    public function BoundsPolygon (polygon :Polygon)
    {
        _polygon = polygon;
    }

    override public function get height () :Number
    {
        return _polygon.boundingBox.height;
    }

    override public function get width () :Number
    {
        return _polygon.boundingBox.width;
    }

    override public function get center () :Vector2
    {
        return _polygon.center;
    }

    public function get polygon () :net.amago.math.geometry.Polygon
    {
        return _polygon;
    }

    public function containsBounds (b :Bounds) :Boolean
    {
        if (b is BoundsPoint) {
            return contains(BoundsPoint(b).point.x, BoundsPoint(b).point.y);
        } else if (b is BoundsLine) {
            var line :LineSegment = BoundsLine(b).lineSegment;
            return contains(line.a.x, line.a.y) && contains(line.b.x, line.b.y);
        } else if (b is BoundsPolygon) {
            return contains(BoundsPolygon(b).polygon.center.x, BoundsPolygon(b).polygon.center.y);
        }
        throw new Error("containsBounds not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));
    }

    public function toString () :String
    {
        return _polygon.toString();
    }

    override public function boundingRect () :Rectangle
    {
        return _polygon.boundingBox;
    }

    override public function clone () :Object
    {
        return new BoundsPolygon(_polygon.clone());
    }

    override public function contains (x :Number, y :Number) :Boolean
    {
        var p :Vector2 = new Vector2(x, y);
        return _polygon.isPointInside(p) || _polygon.isPointOnEdge(p);
    }

    override public function convertToGlobal (localDisp :DisplayObject) :Bounds
    {
        var globalPoints :Array = _polygon.vertices.map(function (v :Vector2,
            ... ignored) :Vector2 {
                return Vector2.fromPoint(localDisp.localToGlobal(v.toPoint()));
            });
        return new BoundsPolygon(new Polygon(globalPoints));
    }

    override public function debugDraw (s :Sprite) :void
    {
        var g :Graphics = s.graphics;
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

    override public function distance (b :Bounds) :Number
    {
        if (b is BoundsPoint) {
            return distanceToPoint(BoundsPoint(b).point);
        } else if (b is BoundsPolygon) {
            return distanceToPoint(BoundsPolygon(b).polygon.center);
        } else if (b is BoundsLine) {
            return _polygon.distanceToLine(BoundsLine(b).lineSegment);
        }
        throw new Error("Distance not implemented between " + ClassUtil.tinyClassName(this) +
            " and " + ClassUtil.tinyClassName(b));

    }

    override public function distanceToPoint (p :Vector2) :Number
    {
        return _polygon.distToPolygonEdge(p);
    }

    override public function getBoundedPoint (targetX :Number, targetY :Number) :Point
    {
        var closestPoint :Vector2 = _polygon.closestPointOnPerimeter(new Vector2(targetX, targetY));
        return closestPoint.toPoint();
    }

    override public function getBoundedPointFromMove (originX :Number, originY :Number,
        targetX :Number, targetY :Number) :Point
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
            var closestPoint :Vector2 = _polygon.closestPointOnPerimeter(new Vector2(targetX,
                targetY));
            return closestPoint.toPoint();
        }

        return Vector2(points[0]).toPoint();
    }

    protected var _polygon :Polygon;

    protected static const log :Log = Log.getLog(BoundsPolygon);
}
}
