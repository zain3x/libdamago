package libdamago.geometry
{
import aduros.util.F;

import com.threerings.geom.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;
import com.threerings.util.Util;

import flash.geom.Rectangle;


public class Polygon
{
    public function Polygon (vertices :Array) //<Vector2>
    {
        if (vertices == null || vertices.length < 3) {
            throw new Error("Cannot create a polygon with < 3 vertices=" + vertices);
        }
        _vertices = vertices;
        polygon = _vertices;

        for (var ii :int = 0; ii < _vertices.length - 1; ++ii) {
            _edges.push(new LineSegment(_vertices[ii], _vertices[ii + 1]));
        }
        _edges.push(new LineSegment(_vertices[_vertices.length - 1], _vertices[0]));
    }

    public function get vertices () :Array
    {
        return _vertices;
    }

    public function get edges () :Array
    {
        return _edges;
    }

    public function distToPolygonEdge (P :Vector2) :Number
    {
        var minDistance :Number = Number.MAX_VALUE;
        var distance :Number;
        for(var i :int = 0; i < polygon.length - 1; i++) {
            distance = LineSegment.distToLineSegment(polygon[i], polygon[i + 1], P);
            minDistance = Math.min(minDistance, distance);
        }
        return minDistance;
    }

    /**
     * Assumes polygons are not overlapping.
     * Could be made more efficient with sorting of vertices.
     * Untested.
     */
    public function distance (P :Polygon) :Number
    {
        var closestDistance :Number = Number.MAX_VALUE;
        var distance :Number;
        for each (var line1 :LineSegment in P.edges) {
            for each (var line2 :LineSegment in edges) {
                distance = line1.distanceToLineSq(line2);
                if (distance < closestDistance) {
                    closestDistance = distance;
                }
            }
        }
        return Math.sqrt(closestDistance);
    }

    public function closestPoint (P :Vector2) :Vector2
    {
        return closestPointOnPolygon(P, _vertices);
    }

    public function closestEdge (P :Vector2) :LineSegment
    {
        var smallestDistance :Number = Number.MAX_VALUE;
        var distance :Number;
        var closestLine :LineSegment;
        for each (var line :LineSegment in _edges) {
            distance = line.dist(P);
            trace(line + " d=" + distance);
            trace("   distance between points=" + VectorUtil.distance(line.a, P), VectorUtil.distance(line.b, P));
            var closestPoint :Vector2 = new Vector2();
            trace("   d again=" + LineSegment.distToLineSegment(line.a, line.b, P, closestPoint));
            trace("   closest point=" + closestPoint);
            trace("   P=" + P);
            trace("   line=" + line);
            if (distance < smallestDistance) {
                smallestDistance = distance;
                closestLine = line;
            }
        }
        return closestLine;
    }

    /**
     */
    protected static function closestPointOnPolygon (P:Vector2, arrayOfPolygonPoints :Array):Vector2
    {
        var polygon :Array = arrayOfPolygonPoints.slice();
        if(arrayOfPolygonPoints[0] != arrayOfPolygonPoints[ arrayOfPolygonPoints.length - 1]) {
            polygon.push(polygon[0]);
        }

        var distance :Number = Number.MAX_VALUE;
        var closestVector :Vector2;
        for(var k :int = 0; k < polygon.length - 1; k++) {
            var point :Vector2 = new Vector2();
            var currentDistance :Number = LineSegment.distToLineSegment(polygon[k], polygon[k + 1], P, point);
            if( currentDistance < distance) {
                distance = currentDistance;
                closestVector = point;
            }
        }
        return closestVector;

    }

    public static function closestPointWithinPoints (P:Vector2, arrayOfPolygonPoints :Array) :Vector2
    {
        var distance :Number = Number.MAX_VALUE;
        var closestVector :Vector2;
        for each (var v :Vector2 in arrayOfPolygonPoints) {
            var point :Vector2 = new Vector2();
            var currentDistance :Number = VectorUtil.distanceSq(v, P);
            if( currentDistance < distance) {
                distance = currentDistance;
                closestVector = v;
            }
        }
        return closestVector;

    }

    public function closestPointOnPerimeter (v :Vector2) :Vector2
    {
        return closestPointOnPolygon(v, _vertices);
    }

    public static function isCircleIntersectingPolygon (P :Vector2, radius :Number, polygon :Array) :Boolean
    {
        var closestPointOnPolygon :Vector2 = closestPointOnPolygon(P, polygon);
        return VectorUtil.distance(closestPointOnPolygon, P) <= radius;
    }

    public static function polygonFromBoundingBox (rect :Rectangle) :Polygon
    {
        var p :Array = new Array();
        p.push(new Vector2(rect.x, rect.y));
        p.push(new Vector2(rect.x + rect.width, rect.y));
        p.push(new Vector2(rect.x + rect.width, rect.y + rect.height));
        p.push(new Vector2(rect.x, rect.y  + rect.height));
        p.push(p[0]);
        return new Polygon(p);
    }

    public function get boundingBox () :Rectangle
    {
        var maxX :Number = Number.MIN_VALUE;
        var minX :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        for each (var v :Vector2 in _vertices) {
            maxX = Math.max(maxX, v.x);
            minX = Math.min(minX, v.x);
            maxY = Math.max(maxY, v.y);
            minY = Math.min(minY, v.y);
        }

        var width :Number = maxX - minX;
        var height :Number = maxY - minY;
        var rect :Rectangle = new Rectangle(minX, minY, width, height);

        return rect;
    }

    public function clone () :Polygon
    {
        return new Polygon(_vertices.map(F.adapt(function (v :Vector2) :Vector2 {
            return v.clone();
        })));
    }

    public function pad (padding :Number) :Polygon
    {
        return this.clone().padLocal(padding);
    }

    public function padLocal (padding :Number) :Polygon
    {
        //Copy the edges so that the edge vertices are independent
        var lines :Array = _edges.map(Util.adapt(function (line :LineSegment) :LineSegment {
            return line.clone();
        }));

        //Move each line in the direction of the line normal (anti-clockwise).
        for each (var line :LineSegment in lines) {
            var normal :Vector2 = line.normalVector;
            var transform :Vector2 = Vector2.fromAngle(normal.angle, padding);
            line.a.addLocal(transform);
            line.b.addLocal(transform);
        }

        //Add the first line to the end
        lines.push(lines[0]);

        //Go though the line pairs and get the intersections as the new polygon vertices
        var newVertices :Array = [];
        for (var ii :int = 0; ii < lines.length - 1; ++ii) {
            var line1 :LineSegment = lines[ii] as LineSegment;
            var line2 :LineSegment = lines[ii + 1] as LineSegment;
            newVertices.push(LineSegment.lineIntersectLine(line1.a, line1.b, line2.a, line2.b, false));
        }

        //Set the polygon vertices to the new values
        for (ii = 0; ii < newVertices.length; ++ii) {
            var newV :Vector2 = newVertices[ii] as Vector2;
            var oldV :Vector2 = _vertices[ii] as Vector2;
            oldV.x = newV.x;
            oldV.y = newV.y;
        }

        return this;
    }
    /**
     * Pad polygon, i.e. enlarge by <padding>.  This ensures that
     * a big fat pathfinder will not hit the walls.  This can be a negative number to unpad.
     */
    protected static function padPolygon(polygon :Array, padding :Number) :void
    {


        var center :Vector2 = getPolygonCenter( polygon );
        //Go through all edges.
        for( var k :int = 0; k < polygon.length - 1; k++) {
            padEdge( polygon[k], polygon[ k + 1 ], center);
        }

        function padEdge( v1 :Vector2, v2 :Vector2, center :Vector2) :void
        {
            //Get the normal
            var normalAngle :Number = MathUtil.normalizeRadians( VectorUtil.angleFrom(v1.x, v1.y, v2.x, v2.y) + Math.PI / 2 );
            //Create the transform vector from the normal angle and the padding
            var transform :Vector2 = Vector2.fromAngle(normalAngle);
            //Check if the angle is pointing the wrong way (to the center instead of away)
            var middlePoint :Vector2 = new Vector2( v1.x + (v2.x - v1.x) / 2, v1.y + (v2.y - v1.y) / 2);

            if( VectorUtil.distance(center, middlePoint) > VectorUtil.distance(center, middlePoint.add(transform))) {
                transform = Vector2.fromAngle(MathUtil.normalizeRadians(normalAngle + Math.PI));
            }
            transform.scale( padding );
            //Change the vertex positions
            v1.addLocal( transform );
            v2.addLocal( transform );
        }












//        return;
//        log.info("padPolygon", "polygon", polygon, "padding", padding);
//        var ii :int;
//
//        //Create an array of line segments
//        var sides :Array = [];
//        for(ii = 0; ii < polygon.length - 1; ii++) {
//            sides.push([Vector2(polygon[ii]).clone(), Vector2(polygon[ii + 1]).clone()]);
//        }
//        sides.push([Vector2(polygon[polygon.length - 1]).clone(), Vector2(polygon[0]).clone()]);
//
//        var side :Array;
//        for each (side in sides) {
//            var v1 :Vector2 = side[0] as Vector2;
//            var v2 :Vector2 = side[1] as Vector2;
//            var normal :Number = VectorUtil.simplifyRadian(VectorUtil.angleFromVectors(v1, v2) + Math.PI / 2);
//            var transform :Vector2 = Vector2.fromAngle(normal, padding);
//            v1.addLocal(transform);
//            v2.addLocal(transform);
//        }
//
////        function computeInter
////
////        for (ii = 0; ii < sides.length; ++ii) {
////
////        }
//
//
//
//
//
//
//
//
//
//        var center :Vector2 = getPolygonCenter(polygon);
//        //Go through all edges.
//        var anglesToProjectAlong :Array = [];
//        for(var k :int = 0; k < polygon.length; k++) {
//
////            if (k == polygon.length - 1 && polygon[0] == polygon[polygon.length - 1]) {
////                continue;
////            }
//
//            var v1 :Vector2 = polygon[k] as Vector2;
//            var v2 :Vector2 = k < polygon.length - 1 ? polygon[k + 1] as Vector2 : polygon[0] as Vector2;
//            var v3 :Vector2 = k > 0 ? polygon[k - 1] as Vector2 : polygon[polygon.length - 1] as Vector2;
//
////            var anglev1v2 :Number = Geometry.angleFromVectors(v1, v2);
////            var angleFromP1 :Number =
////                VectorUtil.simplifyRadian(Math.PI + anglev1v2 + differenceAngles(anglev1v2, Geometry.angleFromVectors(v1, v3)) / 2);
////            anglesToProjectAlong.push(angleFromP1);
//
////            padEdge(polygon[k], polygon[ k + 1 ], center);
//
//
//        }
//
//        for (k = 0; k < anglesToProjectAlong.length; ++k) {
//            trace("adding to", polygon[k],  Vector2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2), ", length=" + Vector2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2).length);
//            Vector2(polygon[k]).addLocal(Vector2.fromAngle(anglesToProjectAlong[k], padding * Math.SQRT2));
//        }
//
////
////        function padEdge(v1 :Vector2, v2 :Vector2, center :Vector2) :void
////        {
////            //Get the normal
////            var normalAngle :Number = MathUtil.normalizeRadians(angleFrom(v1.x, v1.y, v2.x, v2.y) + Math.PI / 2);
////            //Create the transform vector from the normal angle and the padding
////            var transform :Vector2 = Vector2.fromAngle(normalAngle);
////            //Check if the angle is pointing the wrong way (to the center instead of away)
////            var middlePoint :Vector2 = new Vector2(v1.x + (v2.x - v1.x) / 2, v1.y + (v2.y - v1.y) / 2);
////
////            if(distance(center, middlePoint) > distance(center, middlePoint.clone().addLocal(transform))) {
////                transform = Vector2.fromAngle(MathUtil.normalizeRadians(normalAngle + Math.PI));
////            }
////            transform.scaleLocal(padding);
////            //Change the vertex positions
////            v1.addLocal(transform);
////            v2.addLocal(transform);
////        }
    }


    /**
     * Tests two polygons for intersection. *does not check for enclosure*
     * @param object1 an array of Vector points comprising polygon 1
     * @param object2 an array of Vector points comprising polygon 2
     * @return true is intersection occurs
     *
     */
    public static function isObjectOverlapping (object1 :Array, object2 :Array) :Boolean
    {
        for (var i:int=0; i < object1.length; i++){
            for (var j:int=0; j < object2.length; j++){
                if(LineSegment.lineIntersectLine(object2[j], object2[j+1], object1[i],
                    object1[i+1]) != null) {

                    return true;
                }
            }
        }
        return false;
    }


    /**
     * Returns true if any two edges of two polygons intersect, or if any points of one
     * polygon are inside the other polygon.
     * @param P1 Array of Vector2 points, with the first point also last in the array.
     * @param P2 Array of Vector2 points, with the first point also last in the array.
     */
    public function isIntersection (polygon :Polygon) :Boolean
    {
        if (isEdgesIntersecting(polygon)) {
            return true;
        }
        //Vertices exactly on edges are missed.  Check for this.
        if(isHorizontalIntersection(polygon) && isVerticalIntersection(polygon)) {
            return true;
        }

//        var v :Vector2;
//        for each (v in P1) {
//            if (isPointInPolygon(v, P2)) {
//                return true;
//            }
//        }
//        for each (v in P2) {
//            if (isPointInPolygon(v, P1)) {
//                return true;
//            }
//        }

        return false;
    }


    public function isEdgesIntersecting (p :Polygon) :Boolean
    {
        for each (var line :LineSegment in p) {
            if (isLineIntersecting(line.a, line.b)) {
                return true;
            }
        }
        return false;
    }

    public function isLineIntersecting (v1 :Vector2, v2 :Vector2) :Boolean
    {
        for each (var line :LineSegment in _edges) {

            if (LineSegment.isConnected(v1, v2, line.a, line.b)) {
                continue;
            }

            if (line.isIntersected(v1, v2)) {
//                trace(v1, v2, " intersects ", line);
                return true;
            }
        }
        return false;
    }

    public function isLineEnclosed (line :LineSegment) :Boolean
    {
        return isPointInside(line.a) && isPointInside(line.b);
    }

    public function isLineOverlapping (line :LineSegment) :Boolean
    {
        return isLineIntersecting(line.a, line.b) || isLineEnclosed(line);
    }

    public function isPointInside (P :Vector2) :Boolean
    {
        return isPointInPolygon(P, _vertices);
    }

    /**
     * Does not check if a point is ON the polygon edge.
     *
     */
    public static function isPointInPolygon (P :Vector2, arrayOfPolygonPoints :Array) :Boolean
    {
        //First check if the point is one of the vertices
        for each (var v :Vector2 in arrayOfPolygonPoints) {
            if(P.x == v.x && P.y == v.y) {
                return true;
            }
        }


        //Get details of the polygon
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;

        for each (v in arrayOfPolygonPoints) {
            minX = Math.min(minX, v.x);
            maxX = Math.max(maxX, v.x);
            minY = Math.min(minY, v.y);
            maxY = Math.max(maxY, v.y);
        }

        if(P.x < minX ||
            P.x > maxX ||
            P.y < minY ||
            P.y > maxY) {
                return false;
            }

        var width :Number = maxX - minX;
        var height :Number = maxY - minY;
        var center :Vector2 = new Vector2(minX + width / 2, minY + height / 2);

        var angleFromPtoCenter :Number = center.subtract(P).angle;
        //We're lazy: instead of making sure our ray doesn't intersect a vertex,
        //(which would lead to two edge intersections, which would wrongly return the
        //point as outside the polygon), we add a tiny amount to the angle to the
        //center, so as to make the chance of exactly hitting a vertex very remote.
        angleFromPtoCenter += 0.000000123;

        //From P to a point outside the polygon
        var point2 :Vector2 = Vector2.fromAngle(angleFromPtoCenter, Math.max(width, height) *2);

        var polygon :Array = arrayOfPolygonPoints.slice();
        if(arrayOfPolygonPoints[0] != arrayOfPolygonPoints[ arrayOfPolygonPoints.length - 1]) {
            polygon.push(polygon[0]);
        }

        var intersectionsCount :int = 0;
        //If there are an even number of intersections of the ray and the polygon
        //edges, the point lies outside the polygon.
        for(var k :int = 0; k < polygon.length - 1; k++) {
            if(LineSegment.isLinesIntersecting(P, point2, polygon[k], polygon[k + 1])) {
                intersectionsCount++;
            }
        }
        return !(intersectionsCount % 2 == 0);
    }

    public function isPointsAnEdge (p1 :Vector2, p2 :Vector2) :Boolean
    {
        for each (var edge :LineSegment in _edges) {
            if (edge.equalToPoints(p1, p2)) {
                return true;
            }
        }
        return false;
    }


    /**
     * Returns true if any points are an edge of the polygon.
     * @param P1 Array of Vector2 points, with the first point also last in the array.
     */
    protected static function isPolygonEdge(P1 :Vector2, P2 :Vector2, polygon :Array) :Boolean
    {
        for(var k :int = 0; k < polygon.length - 1; k++) {

            var p1 :Vector2 = polygon[k] as Vector2;
            var p2 :Vector2 = polygon[k + 1] as Vector2;

            if((P1.x == p1.x && P1.y == p1.y && P2.x == p2.x && P2.y == p2.y) ||
                (P2.x == p1.x && P2.y == p1.y && P1.x == p2.x && P1.y == p2.y)) {
                    return true;
                }
        }
        return false;
    }

    public function isEdge (A :Vector2, B :Vector2) :Boolean
    {
        for (var ii :int = 0; ii < _vertices.length; ++ii) {
            if (A.equals(_vertices[ii])) {
                //Before current
                var idx :int = ii > 0 ? ii - 1 : _vertices.length - 1;
                if (B.equals(_vertices[idx])) {
                    return true;
                }
                //After current
                idx = ii == _vertices.length - 1 ? 0 : ii + 1;
                if (B.equals(_vertices[idx])) {
                    return true;
                }
            }
        }
        return false;
    }

    /**
     * Returns true if any points are an edge of the polygon.
     * @param P1 Array of Vector2 points, with the first point also last in the array.
     */
    public function isLineOnPolygonEdge(P1 :Vector2, P2 :Vector2) :Boolean
    {
        for each (var edge :LineSegment in _edges) {
            if (edge.dist(P1) == 0 && edge.dist(P2) == 0) {
                return true;
            }
        }
        return false;
    }

    public function isPointOnEdge (P :Vector2) :Boolean
    {
        for each (var line :LineSegment in _edges) {
            if (line.dist(P) == 0) {
                return true;
            }
        }
        return false;
    }


//    public function getIntersectionPoints (line :LineSegment) :Array
    public function getIntersectionPoints (v1 :Vector2, v2 :Vector2) :Array
    {
        var points :Array = [];
        for each (var edge :LineSegment in _edges) {
            var v :Vector2 = edge.intersectionPointLinePoints(v1, v2);
            points.push(v);
        }
        ArrayUtil.removeAll(points, null);
        return points;
    }


    public static function getPointsWhereLineIntersectsPolygon(A:Vector2, B:Vector2, polygon:Array):Array
    {
        var intersectingPoints :Array = new Array();
        for (var i:int = 0; i < polygon.length - 1; i++){
            var point :Vector2 = LineSegment.lineIntersectLine(A, B, polygon[i], polygon[i+1]);
            if(point != null) {
                if(!point.equals(A) && !point.equals(B)) {
                    intersectingPoints.push(point);
                }
            }
        }
        return intersectingPoints;
    }

    public function getClosestPoint (P :Vector2) :Vector2
    {
        var distanceSq :Number = Number.MAX_VALUE;
        var closestVector :Vector2;
        for each (var edge :LineSegment in _edges) {
            var v :Vector2 = edge.closestPointTo(P);
            var d :Number = VectorUtil.distanceSq(P, v);
            if (d < distanceSq) {
                distanceSq = d;
                closestVector = v;
            }
        }
        return closestVector;
    }

    public function isCircleIntersecting (P :Vector2, radius :Number) :Boolean
    {
        var closestPointOnPolygon :Vector2 = getClosestPoint(P);
        return VectorUtil.distance(closestPointOnPolygon, P) <= radius;
    }

    public static function getPolygonCenter (arrayOfPolygonPoints :Array,
        center :Vector2 = null) :Vector2
    {
        var minX :Number = Number.MAX_VALUE;
        var maxX :Number = Number.MIN_VALUE;
        var minY :Number = Number.MAX_VALUE;
        var maxY :Number = Number.MIN_VALUE;

        for each (var v :Vector2 in arrayOfPolygonPoints) {
            minX = Math.min(minX, v.x);
            maxX = Math.max(maxX, v.x);
            minY = Math.min(minY, v.y);
            maxY = Math.max(maxY, v.y);
        }

        if(center == null) {
            center = new Vector2(minX + (maxX - minX) / 2, minY + (maxY - minY) / 2);
        }
        else {
            center.x = minX + (maxX - minX) / 2;
            center.y = minY + (maxY - minY) / 2;
        }
        return center;
    }

    public function get center () :Vector2
    {
        var c :Vector2 = new Vector2();
        getPolygonCenter(_vertices, c);
        return c;
    }


    /**
     * Given two polygons, returns true if they intersect on the y axis.  Note, the x axis is
     * INGORED, so the polygons may not actually intersect in 2D space.
     *
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @return true if the y spaces intersect.
     *
     */
    public function isVerticalIntersection (p :Polygon) :Boolean
    {
        var pBounds :Rectangle = p.boundingBox;
        var bounds :Rectangle = boundingBox;
        var minY1 :Number = bounds.top;
        var maxY1 :Number = bounds.bottom;

        var minY2 :Number = pBounds.top;
        var maxY2 :Number = pBounds.bottom;

        if(NumberUtil.isNumberWithinRange(minY2, minY1, maxY1) ||
            NumberUtil.isNumberWithinRange(maxY2, minY1, maxY1) ||
            NumberUtil.isNumberWithinRange(minY1, minY2, maxY2) ||
            NumberUtil.isNumberWithinRange(maxY1, minY2, maxY2)) {
                return true;
            }

        return false

    }

    public function isVerticalContained (p :Polygon) :Boolean
    {
        var pBounds :Rectangle = p.boundingBox;
        var bounds :Rectangle = boundingBox;
        var minY1 :Number = bounds.top;
        var maxY1 :Number = bounds.bottom;

        var minY2 :Number = pBounds.top;
        var maxY2 :Number = pBounds.bottom;

        if ((NumberUtil.isNumberWithinRange(minY2, minY1, maxY1) &&
            NumberUtil.isNumberWithinRange(maxY2, minY1, maxY1)) ||
            (NumberUtil.isNumberWithinRange(minY1, minY2, maxY2) &&
            NumberUtil.isNumberWithinRange(maxY1, minY2, maxY2))) {
                return true;
            }

        return false

    }

    /**
     * Given two polygons, returns true if they intersect on the x axis.  Note, the y axis is
     * INGORED, so the polygons may not actually intersect in 2D space.
     *
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @return true if the x spaces intersect.
     *
     */
    public function isHorizontalIntersection (p :Polygon) :Boolean
    {
        var pBounds :Rectangle = p.boundingBox;
        var bounds :Rectangle = boundingBox;
        var minX1 :Number = bounds.left;
        var maxX1 :Number = bounds.right;

        var minX2 :Number = pBounds.left;
        var maxX2 :Number = pBounds.right;

        if (NumberUtil.isNumberWithinRange(minX2, minX1, maxX1) ||
            NumberUtil.isNumberWithinRange(maxX2, minX1, maxX1) ||
            NumberUtil.isNumberWithinRange(minX1, minX2, maxX2) ||
            NumberUtil.isNumberWithinRange(maxX1, minX2, maxX2)) {
                return true;
            }

        return false

    }

    public function isHorizontallyContained (p :Polygon) :Boolean
    {
        var pBounds :Rectangle = p.boundingBox;
        var bounds :Rectangle = boundingBox;
        var minX1 :Number = bounds.left;
        var maxX1 :Number = bounds.right;

        var minX2 :Number = pBounds.left;
        var maxX2 :Number = pBounds.right;

        if((NumberUtil.isNumberWithinRange(minX2, minX1, maxX1) &&
            NumberUtil.isNumberWithinRange(maxX2, minX1, maxX1)) ||
            (NumberUtil.isNumberWithinRange(minX1, minX2, maxX2) &&
            NumberUtil.isNumberWithinRange(maxX1, minX2, maxX2))) {
                return true;
            }

        return false

    }

    public function isPolygonVertex (P :Vector2) :Boolean
    {
        for each (var polygonPoint :Vector2 in _vertices) {
            if(polygonPoint.x == P.x && polygonPoint.y == P.y) {
                return true;
            }
        }
        return false;
    }




    /**
     * Given two polygons, returns all intersection points and points contained in the other polygon.
     * NB: the returned list of points is not a true polygon because the order is arbitrary.
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @param p1 a polygon as an array of points, with the first vertex also in the last position
     * @return an Array containing all points contained in the other polygon and all intersection points.
     *
     */
    public static function getIntersectionBoundingBox_ (p1 :Array, p2 :Array) :Array
    {
        var containedPoints :Array = new Array();
        var v :Vector2;
        var k :int;
        var kk :int;

        //Get the vertices within the other polygon
        for(k = 0; k < p1.length - 1; k++) {
            v = p1[k] as Vector2;
            if(Polygon.isPointInPolygon(v, p2) && !ArrayUtil.contains(containedPoints, v) && v != null) {
                containedPoints.push(v);
            }
        }
        for(k = 0; k < p2.length - 1; k++) {
            v = p2[k] as Vector2;
            if(Polygon.isPointInPolygon(v, p1) && !ArrayUtil.contains(containedPoints, v) && v != null) {
                containedPoints.push(v);
            }
        }

        var intersectionPoints :Array = new Array();
        //Create the intersection points
        for(k = 0; k < p1.length - 1; k++) {
            for(kk = 0; kk < p2.length - 1; kk++) {
                if(LineSegment.isLinesIntersecting(p1[k], p1[k + 1], p2[kk], p2[kk + 1])) {
                    var intersectingPoint :Vector2 = LineSegment.lineIntersectLine(p1[k], p1[k + 1], p2[kk], p2[kk + 1]);
                    if(intersectingPoint != null) {
                        intersectionPoints.push(intersectingPoint);
                    }
                }
            }
        }

        containedPoints = containedPoints.concat(intersectionPoints);
        return containedPoints;
    }

    public function getIntersectionBoundingBox (p :Polygon) :Polygon
    {
        var vs :Array = getIntersectionBoundingBox_(_vertices, p.vertices);
        if (vs != null && vs.length > 2) {
            return new Polygon(vs);
        }
        return null;
    }

//    public function setMaxX (X :Number) :void
//    {
//        _vertices.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.x > X) {
//                  point.x = X;
//              }
//          });
//    }
//    public function setMinX (X :Number) :void
//    {
//        _vertices.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.x < X) {
//                  point.x = X;
//              }
//          });
//    }
//
//      public function setMaxY (points :Array, Y :Number) :void
//    {
//        _vertices.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.y > Y) {
//                  point.y = Y;
//              }
//          });
//    }
//
//    public function setMinY (points :Array, Y :Number) :void
//    {
//        _vertices.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.y < Y) {
//                  point.y = Y;
//              }
//          });
//    }



    /**
     * http://notejot.com/2008/11/convex-hull-in-2d-andrews-algorithm/
     */
    public static function convexHullFromPoints (points :Array) :Array
    {
        var topHull:Array = new Array();
        var bottomHull:Array = new Array();
        var convexHull:Array = new Array();

        if(points.length <= 3) {
            return points;
        }
        else {
            // lexicographic sort, get rid of special cases
            points.sortOn(["x", "y"], Array.NUMERIC);

            // compute top part of hull
            topHull.push(0);
            topHull.push(1);

            for(var i:uint = 2; i < points.length; i++) {
                if(towardsLeft(points[topHull[topHull.length - 2]], points[topHull[topHull.length - 1]], points[i])) {
                    topHull.pop();

                    while(topHull.length >= 2) {
                        if(towardsLeft(points[topHull[topHull.length - 2]], points[topHull[topHull.length - 1]], points[i])) {
                            topHull.pop();
                        }
                        else {
                            topHull.push(i);
                            break;
                        }
                    }
                    if(topHull.length == 1)
                        topHull.push(i);
                }
                else {
                   topHull.push(i);
                }
            }

            // compute bottom part of hull
            bottomHull.push(0);
            bottomHull.push(1);

            for(i = 2; i < points.length; i++) {
                if(!towardsLeft(points[bottomHull[bottomHull.length - 2]], points[bottomHull[bottomHull.length - 1]], points[i])) {
                    bottomHull.pop();

                    while(bottomHull.length >= 2) {
                        if(!towardsLeft(points[bottomHull[bottomHull.length - 2]], points[bottomHull[bottomHull.length - 1]], points[i])) {
                            bottomHull.pop();
                        }
                        else {
                            bottomHull.push(i);
                            break;
                        }
                    }
                    if(bottomHull.length == 1)
                       bottomHull.push(i);
                }
                else {
                   bottomHull.push(i);
                }
            }

            bottomHull.reverse();
            bottomHull.shift();
            convexHull = topHull.concat(bottomHull);


            var convexPoints :Array = convexHull.map(Util.adapt(function (idx :int) :Vector2 {
                return points[idx];
            }));

            //Remove the duplicate end point.
            convexPoints.splice(convexPoints.length - 1, 1);

            return convexPoints;
        }

    }

    protected static function towardsLeft (origin :Vector2, p1 :Vector2, p2 :Vector2) :Boolean
    {
        var tmp1:Vector2 = new Vector2(p1.x - origin.x, p1.y - origin.y);
        var tmp2:Vector2 = new Vector2(p2.x - origin.x, p2.y - origin.y);

        if(((tmp1.x * tmp2.y) - (tmp1.y * tmp2.x)) < 0) {
            return true;
        }
        return false;
    }

    public function union (p :Polygon) :Polygon
    {
        if (!isIntersection(p)) {
            log.debug("union, no intersection", "poly1", this, "poly2", p);
            return new Polygon([]);
        }

        var points :Array = unionPolygons(_vertices, p.vertices);
        if (points != null && points.length > 2) {
            return new Polygon(points);
        }
        return null;

    }

    public static function unionPolygons (poly1 :Array, poly2 :Array) :Array
    {
        var p1Idx :int = 0;
        var p2Idx :int = 0;
        var isCurrentPoly1 :Boolean = true;

        //Make sure both polygons are clockwise
        poly1 = Polygon.isClockwisePolygon(poly1) ? poly1 : poly1.reverse();
        poly2 = Polygon.isClockwisePolygon(poly2) ? poly2 : poly2.reverse();

        function vectors2SequentialPairs (v :Vector2, index :int, arr :Array) :Array {
            var index2 :int = index + 1 >= arr.length ? 0 : index + 1;
            return [v, arr[index2]];
        }

        var poly1VectorPairs :Array = poly1.map(vectors2SequentialPairs);
        var poly2VectorPairs :Array = poly2.map(vectors2SequentialPairs);

//        trace("poly1VectorPairs=" + poly1VectorPairs.join("|"));

        var union :Array = [];

        //While the union is too small and isn't closed
        var iterations :int = 0;
        var maxIteractions :int = poly1.length * poly2.length + 2;
        while (union.length < 2 || !Vector2(union[0]).equals(union[union.length - 1] as Vector2)) {
//            trace("\niteration=" + iterations + ", union=" + union);
            iterations++;
            if (iterations > maxIteractions) {
                break;
            }
            //Alternate between the polygons as we trace the union edges from the composite
            //boundary
            var currentPoly :Array = isCurrentPoly1 ? poly1 : poly2;
            var otherPoly :Array = isCurrentPoly1 ? poly2 : poly1;
            var idx :int = isCurrentPoly1 ? p1Idx : p2Idx;

            function setOtherPolyIndex (otherIdx :int, isPoly1 :Boolean) :void {

            }

            var A :Vector2 = currentPoly[idx] as Vector2;
            var B :Vector2 = currentPoly[idx + 1 >= currentPoly.length ? 0 : idx + 1] as Vector2;

//            trace("p1Idx=" + p1Idx);
//            trace("p2Idx=" + p2Idx);
//            trace("isCurrentPoly1=" + isCurrentPoly1);
//            trace("A B=" + [A, B]);

            var closestIntersectionPair :Array = null;
            var closestIntersection :Vector2;
            var closestIntersectionDistanceToFirstPoint :Number = Number.MAX_VALUE;
            var vectorPairs :Array = isCurrentPoly1 ? poly2VectorPairs : poly1VectorPairs;

            //Find the intersection with the closest intersection point to A
            for each (var pair :Array in vectorPairs) {
                var A2 :Vector2 = pair[0] as Vector2;
                var B2 :Vector2 = pair[1] as Vector2;
                var intersection :Vector2 = LineSegment.lineIntersectLine(A, B, A2, B2);
                if (intersection != null) {
                    var dist :Number = VectorUtil.distance(intersection, A);
                    if (dist < closestIntersectionDistanceToFirstPoint) {
                        closestIntersectionDistanceToFirstPoint = dist;
                        closestIntersectionPair = pair;
                        closestIntersection = intersection;
                    }
                }
            }

            if (!Polygon.isPointInPolygon(A, otherPoly)) {
                union.push(A);
            }

            if (closestIntersectionPair != null) {
                A2 = closestIntersectionPair[0] as Vector2;
                B2 = closestIntersectionPair[1] as Vector2;
                union.push(closestIntersection);
                var idxB2 :int = ArrayUtil.indexOf(otherPoly, B2);
//                trace("  idxB2=" + idxB2 + ", B2=" + B2);
//                trace("  intersection " + closestIntersection + " found between " + [A, B, A2, B2]);
                if (Polygon.isPointInPolygon(B2, currentPoly)) {
                    if (isCurrentPoly1) {
                        p1Idx = p1Idx + 1 >= poly1.length ? 0 : p1Idx + 1;
                    } else {
                        p2Idx = p2Idx + 1 >= poly2.length ? 0 : p2Idx + 1;
                    }
//                    trace("    B2 is in this, so incrementing this polygon");
                }
                else {
                    isCurrentPoly1 = !isCurrentPoly1;
                    if (isCurrentPoly1) {
                        p1Idx = idxB2;
                    } else {
                        p2Idx = idxB2;
                    }
//                    trace("    switching polygons");
                }
            }
            else {//No intersections, continue walking around
//                trace("  no intersections, continuing ");
                if (isCurrentPoly1) {
                    p1Idx = p1Idx + 1 >= poly1.length ? 0 : p1Idx + 1;
                } else {
                    p2Idx = p2Idx + 1 >= poly2.length ? 0 : p2Idx + 1;
                }
            }


        }

        return union;
    }

    /**
     * Assumes a convex polygon
     */
    public static function isClockwisePolygon (P :Array) :Boolean
    {
        var A :Vector2 = P[0] as Vector2;
        var B :Vector2 = P[1] as Vector2;
        var C :Vector2 = P[2] as Vector2;

        var angleAB :Number = VectorUtil.angleFromVectors(A, B);
        var angleAC :Number = VectorUtil.angleFromVectors(A, C);

        //If the polygon has vectors in a straight line, choose a different starting vector
        //This could infinitely recurse if P is not a polygon, or made of points that fall
        //on a line
        if (angleAB == angleAC) {
            var differentStartVector :Array = P.concat();
            differentStartVector.unshift(differentStartVector.pop());
            return isClockwisePolygon(differentStartVector);
        }
        else {
            var diff :Number = VectorUtil.differenceAngles(angleAB, angleAC);
            return diff > 0;
        }
    }

    public function toString () :String
    {
        return "\nPolygon[" + _vertices.join(",    ") + "]";
    }

    public function translateLocal (dx :Number, dy :Number) :Polygon
    {
        _vertices.forEach(Util.adapt(function (v :Vector2) :void {
            v.x += dx;
            v.y += dy;
        }));
        return this;
    }



    protected var polygon :Array;
    protected var _vertices :Array;
    protected var _edges :Array = [];
    protected static const log :Log = Log.getLog(Polygon);
}
}
