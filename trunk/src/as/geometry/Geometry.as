
package net.amago.math.geometry
{
import com.threerings.geom.Vector2;
import com.threerings.util.Log;
import com.threerings.util.Util;


public class Geometry
{
    protected static const log :Log = Log.getLog(Geometry);

    public static const PI_HALF :Number = Math.PI / 2;
    public static const PI_2 :Number = Math.PI * 2;
    /**
     * Returns the closest point to A from a list of points.
     * @param A the point to check against.
     * @param otherPoints an arbitrary number of other points.
     * @return the closest point to A.
     *
     */
    public static function closestPoint(A :Vector2, ...otherPoints):Vector2
    {
        otherPoints = Util.unfuckVarargs(otherPoints);
        var closestDistance :Number = Number.MAX_VALUE;
        var closestPoint :Vector2;

        for each (var v :Vector2 in otherPoints)
        {
            var d :Number = VectorUtil.distanceSq(v, A);
            if(d < closestDistance) {
                closestDistance = d;
                closestPoint = v;
            }
        }
        return closestPoint;
    }

    /**
     * Determines how far along a ray an intersection occurs.
     * @param rayOrigin start point of the ray
     * @param rayHeading vector rotation heading of the ray
     * @param planePoint any point on the plane
     * @param planeNormal the normal vector of the plane
     * @return returns negative if the ray is parallel, else the distance along the ray to the intersection.
     *
     */
    public static function distToRayPlaneIntersect(rayOrigin:Vector2, rayHeading:Vector2, planePoint:Vector2, planeNormal:Vector2):Number{
        var d:Number        = -planeNormal.dot(planePoint);
        var numer:Number    = planeNormal.dot(rayOrigin) + d;
        var denom:Number    = planeNormal.dot(rayHeading);

        if ((denom < 0.00001) && (denom > -0.00001)) return -1; //parallel

        return -(numer / denom);
    }

    /**
     * Determines where a point is in relation to a plane
     * @param point the point to check
     * @param pointOnPlane any point on the plane
     * @param planeNormal the vector normal of the plane
     * @return -1 if point is behind plane. 0 if point is on plane. 1 if point is in front of plane.
     *
     */
    public static function whereIsPoint (point :Vector2, pointOnPlane :Vector2,
        planeNormal :Vector2) :int
    {
        var dir:Vector2 = pointOnPlane.subtract(point);

        var d:Number = dir.dot(planeNormal);

        if(d < -0.00001) return 1;

        if(d > 0.00001) return -1;

        return 0;
    }

    /**
     * Determines the distance to the first intersecting point of a ray / circle collision
     * @param rayOrigin the start point of the ray
     * @param rayHeading the rotation vector of the ray
     * @param circleCenter the middle point of the circle
     * @param radius radius of the circle
     * @return returns the distance, or -1 if there is no intersection
     *
     */
    public static function getRayCircleIntersect (rayOrigin :Vector2, rayHeading :Vector2,
        circleCenter :Vector2, radius :Number) :Number
    {
        var toCircle:Vector2    = circleCenter.subtract(rayOrigin);
        var length:Number       = toCircle.length;
        var v:Number            = toCircle.dot(rayHeading);
        var d:Number            = radius * radius - (length * length - v * v);

        if (d < 0) return (-1);

        return (v - Math.sqrt(d));
    }

    /**
     * Same as 'getRayCircleIntersect' except this returns IF there is an intersect to save time on sqrt check
     * @param rayOrigin the start point of the ray
     * @param rayHeading the rotation vector of the ray
     * @param circleCenter the middle point of the circle
     * @param radius radius of the circle
     * @return returns true if intersecting else false
     *
     */
    public static function doesRayIntersectCircle (rayOrigin :Vector2, rayHeading :Vector2,
        circleCenter :Vector2, radius :Number) :Boolean
    {
        var toCircle:Vector2     = circleCenter.subtract(rayOrigin);
        var length:Number         = toCircle.length;
        var v:Number            = toCircle.dot(rayHeading);
        var d:Number            = radius * radius - (length * length - v * v);

        return (d < 0);
    }

    /**
     * Given a point 'P' and a circle of radius 'R' centered at 'C' this function
     * determines the two points on the circle that intersect with the tangents
     * from P to the circle. The points will be given through the
     * 'tangent1' and 'tangent2' variables.
     * @param C point circle is centered on
     * @param R radius of the circle
     * @param P point to check
     * @param tangent1 the first tangent to be constructed
     * @param tangent2 the 2nd tangent to be constructed
     * @return false if 'P' is within the circle
     *
     */
    public static function getTangentPoints (C :Vector2, R :Number, P :Vector2, tangent1 :Vector2,
        tangent2 :Vector2) :Boolean
    {
        var PmC:Vector2       = P.subtract(C);
        var sqrLen :Number    = lengthSq(PmC);
        var rSqr :Number      = R*R;
        if(sqrLen <= rSqr) {
            return false;
        }

        var invSqrLen:Number    = 1 / sqrLen;
        var root:Number            = Math.sqrt(Math.abs(sqrLen - rSqr))

        tangent1.x = C.x + R*(R*PmC.x - PmC.y*root)*invSqrLen;
        tangent1.y = C.y + R*(R*PmC.y - PmC.x*root)*invSqrLen;
        tangent2.x = C.x + R*(R*PmC.x - PmC.y*root)*invSqrLen;
        tangent2.y = C.y + R*(R*PmC.y - PmC.x*root)*invSqrLen;

        return true;
    }

//        /**
//         * Given a line segment AB and a point P, this function calculates the
//         * perpendicular distance between them.
//         * @param A the first point of the line segment
//         * @param B the 2nd point of the line segment
//         * @param P the point to check against
//         * @return the distance from P -> AB
//         *
//         */
//        public static function distToLineSegment (A :Vector2, B :Vector2, P :Vector2) :Number
//        {
//            return Math.sqrt(distToLineSegmentSq(A, b, P));
//        }

//    /**
//     * Given a line segment AB and a point P, this function calculates the
//     * perpendicular distance [Squared] between them to avoid the sqrt.
//     * @param A the first point of the line segment
//     * @param B the 2nd point of the line segment
//     * @param P the point to check against
//     * @return the distance from P -> AB
//     *
//     */
//    public static function distToLineSegmentSq (A:Vector2, B:Vector2, P:Vector2) :Number
//    {
//        var dotA:Number = (P.x - A.x)*(B.x - A.x) + (P.y - A.y)*(B.y - A.y);
//
//        if (dotA <= 0) returnVectorUtil.distanceSq(A, P);
//
//        var dotB:Number = (P.x - B.x)*(A.x - B.x) + (P.y - B.y)*(A.y - B.y);
//
//        if (dotB <= 0) returnVectorUtil.distanceSq(B, P);
//
//        // .. Find closest point to P on line segment ...
//        var point:Vector2 = B.subtract(A);
//        point.scaleLocal(dotA);
//        point.scaleLocal(1/(dotA+dotB));
//        point.addLocal(A);
//
//        returnVectorUtil.distanceSq(P, point);
//    }

//    public static function distToPolygonEdge(P :Vector2, polygon :Array) :Number
//    {
//        var minDistance :Number = Number.MAX_VALUE;
//        var distance :Number;
//        for(var i :int = 0; i < polygon.length - 1; i++) {
//            distance = distToLineSegment(polygon[i], polygon[i + 1], P);
//            minDistance = Math.min(minDistance, distance);
//        }
//        return minDistance;
//    }
//
//    public static function normalOfClosestPolygonEdge(P :Vector2, polygon :Array) :Number
//    {
//        var minDistance :Number = Number.MAX_VALUE;
//        var minDistanceVertexIndex1 :int = 0;
//        var minDistanceVertexIndex2 :int = 0;
//        var distance :Number;
//        for(var i :int = 0; i < polygon.length - 1; i++) {
//            distance = distToLineSegment(polygon[i], polygon[i + 1], P);
//            if(distance < minDistance) {
//                minDistanceVertexIndex1 = i;
//                minDistanceVertexIndex2 = i + 1;
//                minDistance = distance;
//            }
//        }
//        distance = distToLineSegment(polygon[0], polygon[polygon.length - 1], P);
//        if(distance < minDistance) {
//            minDistanceVertexIndex1 = 0;
//            minDistanceVertexIndex2 = polygon.length - 1;
//            minDistance = distance;
//        }
//        var segmentAngle :Number = angleFrom(polygon[minDistanceVertexIndex1].x, polygon[minDistanceVertexIndex1].y, polygon[minDistanceVertexIndex2].x, polygon[minDistanceVertexIndex2].y);
//        segmentAngle = MathUtil.normalizeRadians(segmentAngle - Math.PI / 2);
//        return segmentAngle;
//    }

//    public static function getAllEdgeMidpointsAsPolygon(polygon :Array) :Array
//    {
//        var midpoints :Array = new Array();
//        for(var i :int = 0; i < polygon.length - 1; i++) {
//            midpoints.push(Vector2.interpolate(polygon[i], polygon[i + 1], 0.5));
//        }
//        return midpoints;
//    }

//    public static function polygonFromBoundingBox(rect :Rectangle) :Array
//    {
//        var p :Array = new Array();
//        p.push(new Vector2(rect.x, rect.y));
//        p.push(new Vector2(rect.x + rect.width, rect.y));
//        p.push(new Vector2(rect.x + rect.width, rect.y + rect.height));
//        p.push(new Vector2(rect.x, rect.y  + rect.height));
//        p.push(p[0]);
//        return p;
//    }
//
//    public static function boundingBoxFromPolygon(poly :Array) :Rectangle
//    {
//        var width :Number = width(poly);
//        var height :Number = height(poly);
//        var minX :Number = minX(poly);
//        var minY :Number = minY(poly);
//        var rect :Rectangle = new Rectangle();
//
//        rect.x = minX;
//        rect.y = minY;
//        rect.width = width;
//        rect.height = height;
//
//        return rect;
//    }


//    /**
//    * Pad polygon, i.e. enlarge by <padding>.  This ensures that
//    * a big fat pathfinder will not hit the walls.  This can be a negative number to unpad.
//    */
//    public static function padPolygon(polygon :Array, padding :Number) :void
//    {
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
//            var normal :Number = VectorUtil.simplifyRadian(angleFromVectors(v1, v2) + Math.PI / 2);
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
//            var anglev1v2 :Number = Geometry.angleFromVectors(v1, v2);
//            var angleFromP1 :Number =
//                VectorUtil.simplifyRadian(Math.PI + anglev1v2 + differenceAngles(anglev1v2, Geometry.angleFromVectors(v1, v3)) / 2);
//            anglesToProjectAlong.push(angleFromP1);
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
//    }





//    /**
//     * Given 2 lines in 2D space AB, CD this returns true if an intersection occurs
//     * @param A Start point of line 1.
//     * @param B End point of line 1.
//     * @param C Start point of line 2.
//     * @param D End point of line 2.
//     * @return true if intersection occurs
//     *
//     */
//    public static function isLineIntersecting (A:Vector2, B:Vector2, C:Vector2, D:Vector2):Boolean{
//        var rTop:Number = (A.y-C.y)*(D.x-C.x)-(A.x-C.x)*(D.y-C.y);
//        var sTop:Number = (A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
//        var bot:Number     = (B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
//
//        if(bot == 0) return false; //parallel
//
//        var invBot:Number     = 1 / bot;
//        var r:Number        = rTop * invBot;
//        var s:Number        = sTop * invBot;
//
//        if((r > 0) && (r < 1) && (s > 0) && (s < 1)) return true;
//
//        return false;
//    }

//    //---------------------------------------------------------------
//    //Checks for intersection of Segment if as_seg is true.
//    //Somewhat more reliabel than the above
//    //Checks for intersection of Line if as_seg is false.
//    //Return intersection of Segment "AB" and Segment "EF" as a Point
//    //Return null if there is no intersection
//    //---------------------------------------------------------------
//    protected function lineIntersectLine(A:Vector2,B:Vector2,E:Vector2,F:Vector2,as_seg:Boolean=true):Vector2
//    {
//        var ip:Vector2;
//        var a1:Number;
//        var a2:Number;
//        var b1:Number;
//        var b2:Number;
//        var c1:Number;
//        var c2:Number;
//
//        a1= B.y-A.y;
//        b1= A.x-B.x;
//        c1= B.x*A.y - A.x*B.y;
//        a2= F.y-E.y;
//        b2= E.x-F.x;
//        c2= F.x*E.y - E.x*F.y;
//
//        var denom:Number=a1*b2 - a2*b1;
//        if(denom == 0){
//            return null;
//        }
//        ip=new Vector2();
//        ip.x=(b1*c2 - b2*c1)/denom;
//        ip.y=(a2*c1 - a1*c2)/denom;
//
//        //---------------------------------------------------
//        //Do checks to see if intersection to endpoints
//        //distance is longer than actual Segments.
//        //Return null if it is with any.
//        //---------------------------------------------------
//        if(as_seg){
//            if(distance(ip,B) > distance(A,B)){
//                return null;
//            }
//            if(distance(ip,A) > distance(A,B)){
//                return null;
//            }
//
//            if(distance(ip,F) > distance(E,F)){
//                return null;
//            }
//            if(distance(ip,E) > distance(E,F)){
//                return null;
//            }
//        }
//        return ip;
//    }





//    /**
//     * Returns true if any points are an edge of the polygon.
//     * @param P1 Array of Vector2 points, with the first point also last in the array.
//     */
//    public static function isLineOnPolygonEdge(P1 :Vector2, P2 :Vector2, polygon :Array) :Boolean
//    {
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//
//            var p1 :Vector2 = polygon[k] as Vector2;
//            var p2 :Vector2 = polygon[k + 1] as Vector2;
//
//            var distancep1ToEdge :Number = distToLineSegment(polygon[k], polygon[k + 1], P1);
//            var distancep2ToEdge :Number = distToLineSegment(polygon[k], polygon[k + 1], P2);
//
//            if(distancep1ToEdge == 0 && distancep2ToEdge == 0) {
//                return true;
//            }
//        }
//
//        return false;
//    }

//    /**
//     * Returns true if any points are an edge of the polygon.
//     * @param P1 Array of Vector2 points, with the first point also last in the array.
//     */
//    public static function numberVerticesOfPolygonTouchingLine(P1 :Vector2, P2 :Vector2, polygon :Array) :int
//    {
//        var vertexCount :int = 0;
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//
//            var v :Vector2 = polygon[k] as Vector2;
//
//            if(distToLineSegment(P1, P2, polygon[k]) == 0) {
//                vertexCount++;
//            }
//        }
//
//        return vertexCount;
//    }

//    /**
//     * Returns true if any points are an edge of the polygon.
//     * @param P1 Array of Vector2 points, with the first point also last in the array.
//     */
//    public static function getVerticesOfPolygonTouchingLine(P1 :Vector2, P2 :Vector2, polygon :Array) :Array
//    {
//        var vertices :Array = new Array();
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//
//            var v :Vector2 = polygon[k] as Vector2;
//
//            if(distToLineSegment(P1, P2, polygon[k]) == 0) {
//                vertices.push(v);
//            }
//        }
//
//        return vertices;
//    }

//    /**
//     * Given 2 lines in 2D space AB, CD this returns true if an intersection occurs
//     * @param A Start point of line 1.
//     * @param B End point of line 1.
//     * @param C Start point of line 2.
//     * @param D End point of line 2.
//     * @param point A Vector which is set to the point of intersection if one does occur.
//     * @return -1 if no intersection occurs, else returns the distance
//     *
//     */
//    public static function lineIntersection(A:Vector2, B :Vector2, C :Vector2, D :Vector2, point :Vector2):Number{
//        var rTop:Number = (A.y-C.y)*(D.x-C.x)-(A.x-C.x)*(D.y-C.y);
//        var sTop:Number = (A.y-C.y)*(B.x-A.x)-(A.x-C.x)*(B.y-A.y);
//        var rBot:Number = (B.x-A.x)*(D.y-C.y)-(B.y-A.y)*(D.x-C.x);
//        var sBot:Number = (B.x-A.x)*(B.y-A.y)-(B.y-A.y)*(B.x-A.x);
//
//        if((rBot == 0) || (sBot == 0)){
//            //lines are parallel
//            return -1;
//        }
//
//        var r:Number = rTop/rBot;
//        var s:Number = sTop/sBot;
//
//        if((r>0) && (r<1) && (s>0) && (s<1)){
//
//            //A + r * (B - A)
//            point = B.subtract(A);
//            point.scaleLocal(r);
//            point.addLocal(A);
//
//            return distance(A, B) * r;
//        } else {
//            return -1;
//        }
//    }



//
//    //---------------------------------------------------------------
//    //Checks for intersection of Segment if as_seg is true.
//    //Checks for intersection of Line if as_seg is false.
//    //Return intersection of Segment "AB" and Segment "EF" as a Point
//    //Return null if there is no intersection
//    //Replacement for lineIntersection, which does not work
//    //---------------------------------------------------------------
//    public static function lineIntersectLine(A:Vector2,B:Vector2,E:Vector2,F:Vector2,as_seg:Boolean=true):Vector2
//    {
//        var ip:Vector2;
//        var a1:Number;
//        var a2:Number;
//        var b1:Number;
//        var b2:Number;
//        var c1:Number;
//        var c2:Number;
//
//        a1= B.y-A.y;
//        b1= A.x-B.x;
//        c1= B.x*A.y - A.x*B.y;
//        a2= F.y-E.y;
//        b2= E.x-F.x;
//        c2= F.x*E.y - E.x*F.y;
//
//        var denom:Number=a1*b2 - a2*b1;
//        if(denom == 0){
//            return null;
//        }
//        ip=new Vector2();
//        ip.x=(b1*c2 - b2*c1)/denom;
//        ip.y=(a2*c1 - a1*c2)/denom;
//
//        //---------------------------------------------------
//        //Do checks to see if intersection to endpoints
//        //distance is longer than actual Segments.
//        //Return null if it is with any.
//        //---------------------------------------------------
//        if(as_seg){
//            if(distance(ip,B) > distance(A,B)){
//                return null;
//            }
//            if(distance(ip,A) > distance(A,B)){
//                return null;
//            }
//
//            if(distance(ip,F) > distance(E,F)){
//                return null;
//            }
//            if(distance(ip,E) > distance(E,F)){
//                return null;
//            }
//        }
//        return ip;
//    }
//
//    /**
//     * Tests two polygons for intersection. *does not check for enclosure*
//     * @param object1 an array of Vector points comprising polygon 1
//     * @param object2 an array of Vector points comprising polygon 2
//     * @return true is intersection occurs
//     *
//     */
//    public static function isObjectOverlapping(object1:Array, object2:Array):Boolean{
//        for (var i:int=0; i < object1.length; i++){
//            for (var j:int=0; j < object2.length; j++){
//                if(isLineIntersecting(object2[j],object2[j+1],object1[i],object1[i+1])) return true;
//            }
//        }
//        return false;
//    }

//    /**
//     * Tests a line segment for collision against a polygon *does not check for enclosure*
//     * @param A The start point of the line segment.
//     * @param B The end point of the line segment.
//     * @param object An array of vector points comprising the polygon.  The first point must be
//     *  also in the last position.
//     * @return true if intersection occurs
//     *
//     */
//    public static function isLineIntersectingPolygon(A:Vector2, B:Vector2, object:Array):Boolean{
//        for (var i:int=0; i<object.length - 1; i++){
//            if(isLineIntersecting(A,B,object[i],object[i+1])) return true;
//        }
//        if(isLineIntersecting(A,B,object[object.length - 1],object[0])) return true;
//        return false;
//    }

//    /**
//     * Tests a line segment for collision or enclosure against a polygon.
//     * @param A The start point of the line segment.
//     * @param B The end point of the line segment.
//     * @param object An array of vector points comprising the polygon.  The first point must be
//     *  also in the last position.
//     * @return true if intersection or enclosure occurs
//     *
//     */
//    public static function isSegmentOverlappingPolygon (A :Vector2, B :Vector2, object:Array) :Boolean{
//        for (var i:int=0; i<object.length - 1; i++){
//            if(isLineIntersecting(A,B,object[i],object[i+1])) return true;
//        }
//        if(isLineIntersecting(A,B,object[object.length - 1],object[0])) return true;
//
//        if (isPointInPolygon(A, object) || isPointInPolygon(B, object)) {
//            return true;
//        }
//
//        return false;
//    }

//    public static function getPointsWhereLineIntersectsPolygon(A:Vector2, B:Vector2, polygon:Array):Array
//    {
//        var intersectingPoints :Array = new Array();
//        for (var i:int = 0; i < polygon.length - 1; i++){
//            var point :Vector2 = lineIntersectLine(A, B, polygon[i], polygon[i+1]);
//            if(point != null) {
//                if(!point.equals(A) && !point.equals(B)) {
//                    intersectingPoints.push(point);
//                }
//            }
//        }
//        return intersectingPoints;
//    }

    /**
     * Checks to see if two circles are overlapping
     * @param circle1 center point of the 1st circle.
     * @param radius1 radius of circle 1.
     * @param circle2 center point of the 2nd circle.
     * @param radius2 radius of circle 2.
     * @return true if circles are overlapping.
     *
     */
    public static function isCircleOverlapping(circle1:Vector2, radius1:Number, circle2:Vector2, radius2:Number):Boolean{
        var distSq:Number =VectorUtil.distanceSq(circle1, circle2);
         var range:Number = radius1 + radius2;
         if(distSq < range * range){
             return true;
         }
         return false;
    }

    /**
     * Given two circles this function calculates the intersection points
     * of any overlap
     * @param circle1 center point of the 1st circle.
     * @param radius1 radius of circle 1.
     * @param circle2 center point of the 2nd circle.
     * @param radius2 radius of circle 2.
     * @param point1 A Vector returned with the 1st point of intersection.
     * @param point2 A Vector returned with the 2nd point of intersection.
     * @return false if no overlap is found.
     *
     */
    public static function getCircleIntersectionPoints (circle1:Vector2, radius1:Number, circle2:Vector2, radius2:Number, point1:Vector2, point2:Vector2):Boolean{
        if(!isCircleOverlapping(circle1,radius1,circle2,radius2)) return false;

        var dist:Number = VectorUtil.distance(circle1, circle2);

        var a:Number    = (radius1 - radius2 + (dist*dist)) / (2 * dist);
        var b:Number    = (radius2 - radius1 + (dist*dist)) / (2 * dist);

        var p2:Vector2 = new Vector2();
        p2.x = circle1.x + a * (circle2.x - circle1.x) / dist;
        p2.y = circle1.y + a * (circle2.y - circle1.y) / dist;

        var h1:Number = Math.sqrt(radius1*radius1 - a*a);
        point1.x = p2.x - h1 * (circle2.y - circle1.y) / dist;
        point1.y = p2.y - h1 * (circle2.x - circle1.x) / dist;

        var h2:Number = Math.sqrt(radius2*radius2 - a*a);
        point2.x = p2.x - h2 * (circle2.y - circle1.y) / dist;
        point2.y = p2.y - h2 * (circle2.x - circle1.x) / dist;

        return true;
    }

    /**
     * If the two circles overlap, then this function will calculate the area of the union
     * @param circle1 center point of the 1st circle.
     * @param radius1 radius of circle 1.
     * @param circle2 center point of the 2nd circle.
     * @param radius2 radius of circle 2.
     * @return the area of the union, or 0 if no overlap occurs
     *
     */
    public static function getCircleIntersectionArea(circle1:Vector2, radius1:Number, circle2:Vector2, radius2:Number):Number{
        if(!isCircleOverlapping(circle1,radius1,circle2,radius2)) return 0; // no overlap

        var dist:Number = Math.sqrt((circle1.x-circle2.x) * (circle1.x-circle2.x) + (circle1.y-circle2.y) * (circle1.y-circle2.y));

        var CBD:Number = 2 * Math.acos((radius2*radius2 + dist*dist - radius1*radius1) / (radius2 * dist * 2));
        var CAD:Number = 2 * Math.acos((radius1*radius1 + dist*dist - radius2*radius2) / (radius1 * dist * 2));

        var area:Number =     .5*CBD*radius2*radius2 - .5*radius2*radius2*Math.sin(CBD) +
                            .5*CAD*radius1*radius1 - .5*radius1*radius1*Math.sin(CAD);

        return area;
    }

    /**
     * Calculates the area of a circle.
     * @param radius radius of the circle
     * @return the area of the circle
     *
     */
    public static function circleArea(radius:Number):Number{
        return Math.PI * radius * radius;
    }

    /**
     * Determines if a point is within a circle
     * @param circle the center point of the circle
     * @param radius radius of the circle.
     * @param point the point to check
     * @return true if the point is within the circle
     *
     */
    public static function isPointInCircle(circle:Vector2, radius:Number, point:Vector2):Boolean{
        var distSq:Number = lengthSq((point.subtract(circle)));
         if(distSq < (radius * radius)) return true;

         return false;
    }

    /**
     * Determines if a line segment intersects with a circle.
     * @param A Start point of the line.
     * @param B End point of the line.
     * @param circle position of the circle.
     * @param radius radius of the circle.
     * @return true if circle overlaps the line segment
     *
     */
    public static function isCircleOverlappingSegment(A:Vector2, B:Vector2, circle:Vector2, radius:Number):Boolean{

        var distSq:Number = LineSegment.distToLineSegmentSq(A,B,circle);
        if (distSq < radius * radius) return true;
        return false;
    }


    /**
     * Determines if a point is contained within a (rotated) rectangle.
     * @param A Point.
     * @param B Center of rectangle.
     * @return true if point is contained within the rectangle
     *
     */
    public static function isPointInsideRotatedRect(A:Vector2, locX :Number, locY :Number, width :Number, height :Number, angle :Number):Boolean
    {
        var relativePoint :Vector2 = new Vector2(A.x - locX, A.y - locY);
        if(angle != 0) {
            relativePoint.rotateLocal(-angle);
        }
        return relativePoint.x >= -width/2 &&
               relativePoint.x <= width/2 &&
               relativePoint.y <= height/2 &&
               relativePoint.y >= -height/2;
    }

    public static function isPointInsideRect(A:Vector2, x :Number, y :Number, w :Number, h:Number):Boolean
    {
        return A.x >= x &&
               A.x <= x + w &&
               A.y >= y &&
               A.y <= y + h;
    }




    /**
     * Determines if a line and circle intersects, and if so stores the closest intersection
     * point in 'intersectionPoint'
     * @param A Start point of the line.
     * @param B End point of the line.
     * @param circle position of the circle.
     * @param radius radius of the circle.
     * @param intersectionPoint A Vector to store the closest intersection point in.
     * @return false if the two do not intersect.
     *
     */
    public static function getLineCircleClosestIntersection (A:Vector2, B:Vector2, circle:Vector2, radius:Number, intersectionPoint:Vector2):Boolean
    {
        var toBNorm:Vector2 = B.subtract(A).normalize();

        var localPos:Vector2 = Transformations.pointToLocalSpace(circle,toBNorm,toBNorm.getPerp(),A);

        var ipFound:Boolean = false;

        if((localPos.x + radius >= 0) && (localPos.x-radius) <=VectorUtil.distanceSq(B, A)){
            if(Math.abs(localPos.y) < radius){
                var a:Number = localPos.x;
                var b:Number = localPos.y;

                var ip:Number = a - Math.sqrt(radius*radius - b*b);

                if (ip <= 0) ip = a + Math.sqrt(radius*radius - b*b);

                ipFound = true;

                intersectionPoint = A.addLocal(toBNorm.scale(ip));
            }
        }

        return ipFound;
    }

//  /**
//     * Given a line segment AB and a point P, this function calculates the
//     * perpendicular distance between them.
//     * @param A the first point of the line segment
//     * @param B the 2nd point of the line segment
//     * @param P the point to check against
//     * @return the distance from P -> AB
//     *
//     */
//    public static function distToLineSegment (A :Vector2, B :Vector2, P :Vector2, closestPoint :Vector2 = null) :Number
//    {
//
//
//        var dotA:Number = (P.x - A.x)*(B.x - A.x) + (P.y - A.y)*(B.y - A.y);
//
//        if (dotA <= 0) {
//            if(closestPoint != null) {
//                closestPoint.x = A.x;
//                closestPoint.y = A.y;
//            }
//
//            return distance(A, P);
//        }
//
//        var dotB:Number = (P.x - B.x)*(A.x - B.x) + (P.y - B.y)*(A.y - B.y);
//
//        if (dotB <= 0) {
//            if(closestPoint != null) {
//                closestPoint.x = B.x;
//                closestPoint.y = B.y;
//            }
//            return distance(B, P);
//        }
//
//        // .. Find closest point to P on line segment ...
//        var point:Vector2 = B.subtract(A);
//        point.scaleLocal(dotA);
//        point.scale(1 / (dotA+dotB));
//        point.addLocal(A);
//
//        if(closestPoint != null) {
//            closestPoint.x = point.x;
//            closestPoint.y = point.y;
//        }
//
//        return distance(P, point);
//    }

//    /**
//     * Given a line segment AB and a point P, this function calculates the
//     * perpendicular distance between them.
//     * @param A the first point of the line segment
//     * @param B the 2nd point of the line segment
//     * @param P the point to check against
//     * @return the distance from P -> AB
//     *
//     */
//    public static function closestPointOnPolygon(P:Vector2, arrayOfPolygonPoints :Array):Vector2
//    {
//        var polygon :Array = arrayOfPolygonPoints.slice();
//        if(arrayOfPolygonPoints[0] != arrayOfPolygonPoints[ arrayOfPolygonPoints.length - 1]) {
//            polygon.push(polygon[0]);
//        }
//
//        var distance :Number = Number.MAX_VALUE;
//        var closestVector :Vector2;
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//            var point :Vector2 = new Vector2();
//            var currentDistance :Number = Geometry.distToLineSegment(polygon[k], polygon[k + 1], P, point);
//            if( currentDistance < distance) {
//                distance = currentDistance;
//                closestVector = point;
//            }
//        }
//        return closestVector;
//
//    }
//
//    public static function isCircleIntersectingPolygon(P :Vector2, radius :Number, polygon :Array) :Boolean
//    {
//        var closestPointOnPolygon :Vector2 = closestPointOnPolygon(P, polygon);
//        return distance(closestPointOnPolygon, P) <= radius;
//    }

//    public static function getPolygonCenter(arrayOfPolygonPoints :Array, center :Vector2 = null):Vector2
//    {
//        var minX :Number = Number.MAX_VALUE;
//        var maxX :Number = Number.MIN_VALUE;
//        var minY :Number = Number.MAX_VALUE;
//        var maxY :Number = Number.MIN_VALUE;
//
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            minX = Math.min(minX, v.x);
//            maxX = Math.max(maxX, v.x);
//            minY = Math.min(minY, v.y);
//            maxY = Math.max(maxY, v.y);
//        }
//
//        if(center == null) {
//            center = new Vector2(minX + (maxX - minX) / 2, minY + (maxY - minY) / 2);
//        }
//        else {
//            center.x = minX + (maxX - minX) / 2;
//            center.y = minY + (maxY - minY) / 2;
//        }
//        return center;
//
//    }








//    public static function maxY(arrayOfPolygonPoints :Array) :Number
//    {
//        var maxY :Number = Number.MIN_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            maxY = Math.max(maxY, v.y);
//        }
//        return maxY;
//    }
//
//
//    public static function minY(arrayOfPolygonPoints :Array) :Number
//    {
//        var minY :Number = Number.MAX_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            minY = Math.min(minY, v.y);
//        }
//        return minY;
//    }
//    public static function height(arrayOfPolygonPoints :Array) :Number
//    {
//        var maxY :Number = Number.MIN_VALUE;
//        var minY :Number = Number.MAX_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            maxY = Math.max(maxY, v.y);
//            minY = Math.min(minY, v.y);
//        }
//        return maxY - minY;
//    }
//
//    public static function width(arrayOfPolygonPoints :Array) :Number
//    {
//        var maxX :Number = Number.MIN_VALUE;
//        var minX :Number = Number.MAX_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            maxX = Math.max(maxX, v.x);
//            minX = Math.min(minX, v.x);
//        }
//        return maxX - minX;
//    }
//
//    public static function maxX(arrayOfPolygonPoints :Array) :Number
//    {
//        var maxX :Number = Number.MIN_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            maxX = Math.max(maxX, v.x);
//        }
//        return maxX;
//    }
//
//    public static function minX(arrayOfPolygonPoints :Array) :Number
//    {
//        var minX :Number = Number.MAX_VALUE;
//        for each (var v :Vector2 in arrayOfPolygonPoints) {
//            minX = Math.min(minX, v.x);
//        }
//        return minX;
//    }

//    /**
//     * Given two polygons, returns true if they intersect on the y axis.  Note, the x axis is
//     * INGORED, so the polygons may not actually intersect in 2D space.
//     *
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @return true if the y spaces intersect.
//     *
//     */
//    public static function isVerticalIntersection(p1 :Array, p2 :Array) :Boolean
//    {
//        var minY1 :Number = minY(p1);
//        var maxY1 :Number = maxY(p1);
//
//        var minY2 :Number = minY(p2);
//        var maxY2 :Number = maxY(p2);
//
//        if(isNumberWithinRange(minY2, minY1, maxY1) ||
//            isNumberWithinRange(maxY2, minY1, maxY1) ||
//            isNumberWithinRange(minY1, minY2, maxY2) ||
//            isNumberWithinRange(maxY1, minY2, maxY2)) {
//                return true;
//            }
//
//        return false
//
//    }

    /**
    * Is one polygon vertically contained in the other.  Checks for both.
    */
//    public static function isVerticalContained(p1 :Array, p2 :Array) :Boolean
//    {
//        var minY1 :Number = minY(p1);
//        var maxY1 :Number = maxY(p1);
//
//        var minY2 :Number = minY(p2);
//        var maxY2 :Number = maxY(p2);
//
//        if((isNumberWithinRange(minY2, minY1, maxY1) &&
//            isNumberWithinRange(maxY2, minY1, maxY1)) ||
//            (isNumberWithinRange(minY1, minY2, maxY2) &&
//            isNumberWithinRange(maxY1, minY2, maxY2))) {
//                return true;
//            }
//
//        return false
//
//    }

//    /**
//     * Given two polygons, returns true if they intersect on the x axis.  Note, the y axis is
//     * INGORED, so the polygons may not actually intersect in 2D space.
//     *
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @return true if the x spaces intersect.
//     *
//     */
//    public static function isHorizontalIntersection(p1 :Array, p2 :Array) :Boolean
//    {
//        var minX1 :Number = minX(p1);
//        var maxX1 :Number = maxX(p1);
//
//        var minX2 :Number = minX(p2);
//        var maxX2 :Number = maxX(p2);
//
//        if(isNumberWithinRange(minX2, minX1, maxX1) ||
//            isNumberWithinRange(maxX2, minX1, maxX1) ||
//            isNumberWithinRange(minX1, minX2, maxX2) ||
//            isNumberWithinRange(maxX1, minX2, maxX2)) {
//                return true;
//            }
//
//        return false
//
//    }

//    public static function isHorizontallyContained(p1 :Array, p2 :Array) :Boolean
//    {
//        var minX1 :Number = minX(p1);
//        var maxX1 :Number = maxX(p1);
//
//        var minX2 :Number = minX(p2);
//        var maxX2 :Number = maxX(p2);
//
//        if((isNumberWithinRange(minX2, minX1, maxX1) &&
//            isNumberWithinRange(maxX2, minX1, maxX1)) ||
//            (isNumberWithinRange(minX1, minX2, maxX2) &&
//            isNumberWithinRange(maxX1, minX2, maxX2))) {
//                return true;
//            }
//
//        return false
//
//    }


//
//     /**
//     * Returns the closest vertex of the polygon (an array of points) to P
//     */
//    public static function getClosestVertex(P :Vector2, polygon :Array) :Vector2
//    {
//        var distance :Number = Number.MAX_VALUE;
//        var closestVector :Vector2;
//        for(var k :int = 0; k < polygon.length; k++) {
//            var currentDistance :Number = Geometry.distance(P, polygon[k]);
//            if( currentDistance < distance) {
//                distance = currentDistance;
//                closestVector = polygon[k];
//            }
//        }
//        return closestVector;
//    }

//     /**
//     * Returns the closest vertex of the polygon (an array of points) to P
//     */
//    public static function getVerticesInOrderOfDistanceToPoint(P :Vector2, polygon :Array) :Array
//    {
//        var sortedArray :Array = polygon.slice();
//
//        sortedArray.sort(function compareFunction(v1 :Vector2, v2 :Vector2) :int  {
//           var d1 :Number =VectorUtil.distanceSq(v1, P);
//           var d2 :Number =VectorUtil.distanceSq(v2, P);
//           if(d1 < d2) { return -1; }
//           else if(d1 > d2) { return 1;}
//           return 0;
//        });
//
//        return sortedArray;
//    }


    /**
     * Returns true if all the given points are equal to one of the polygon points.
     */
//    public static function isPolygonVertex (polygon :Array, P :Vector2) :Boolean
//    {
//        for each (var polygonPoint :Vector2 in polygon) {
//            if(polygonPoint.x == P.x && polygonPoint.y == P.y) {
//                return true;
//            }
//        }
//        return false;
//    }

//    public static function isPointsEqualToPolygonEdge(A :Vector2, B :Vector2, polygon :Array) :Boolean
//    {
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//            var v1 :Vector2 = polygon[k] as Vector2;
//            var v2 :Vector2 = polygon[k + 1] as Vector2;
//            if((A.equals(v1) && B.equals(v2)) || (A.equals(v2) && B.equals(v1))) {
//                return true;
//            }
//        }
//        return false;
//    }

//    public static function isPointOnPolygonEdge(P :Vector2, polygon :Array) :Boolean
//    {
//        for(var k :int = 0; k < polygon.length - 1; k++) {
//            if(distToLineSegment(polygon[k], polygon[k + 1], P) == 0) {
//                return true;
//            }
//        }
//        return false;
//    }

//    /**
//     * Orders a set of points so that no line segments intersect.
//     */
//    public static function orderPointsToCreatePolygon(points :Array) :Array
//    {
////            function lineSegmentsIntersect(polygon :Array) :Boolean
////            {
////                var intersects :Boolean = false;
////                for(var k :int = 0; k < polygon.length - 1; k++) {
////
////                }
////            }
//        return points;
//    }

//    /**
//     * Given two polygons, returns all intersection points and points contained in the other polygon.
//     * NB: the returned list of points is not a true polygon because the order is arbitrary.
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @param p1 a polygon as an array of points, with the first vertex also in the last position
//     * @return an Array containing all points contained in the other polygon and all intersection points.
//     *
//     */
//    public static function getIntersectionBoundingBox(p1 :Array, p2 :Array) :Array
//    {
//        var containedPoints :Array = new Array();
//        var v :Vector2;
//        var k :int;
//        var kk :int;
//
//        //Get the vertices within the other polygon
//        for(k = 0; k < p1.length - 1; k++) {
//            v = p1[k] as Vector2;
//            if(Geometry.isPointInPolygon(v, p2) && !ArrayUtil.contains(containedPoints, v) && v != null) {
//                containedPoints.push(v);
//            }
//        }
//        for(k = 0; k < p2.length - 1; k++) {
//            v = p2[k] as Vector2;
//            if(Geometry.isPointInPolygon(v, p1) && !ArrayUtil.contains(containedPoints, v) && v != null) {
//                containedPoints.push(v);
//            }
//        }
//
//        var intersectionPoints :Array = new Array();
//        //Create the intersection points
//        for(k = 0; k < p1.length - 1; k++) {
//            for(kk = 0; kk < p2.length - 1; kk++) {
//                if(Geometry.isLineIntersecting(p1[k], p1[k + 1], p2[kk], p2[kk + 1])) {
//                    var intersectingPoint :Vector2 = Geometry.lineIntersectLine(p1[k], p1[k + 1], p2[kk], p2[kk + 1]);
//                    if(intersectingPoint != null) {
//                        intersectionPoints.push(intersectingPoint);
//                    }
//                }
//            }
//        }
//
//        containedPoints = containedPoints.concat(intersectionPoints);
//        return containedPoints;
//    }

//    public static function makeAllPointsLessThanX(points :Array, X :Number) :void
//    {
//        points.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.x > X) {
//                  point.x = X;
//              }
//          });
//    }
//    public static function makeAllPointsMoreThanX(points :Array, X :Number) :void
//    {
//        points.forEach(function(point :Vector2, ...ignored) :void {
//              if(point.x < X) {
//                  point.x = X;
//              }
//          });
//    }








//    /**
//     * Same as <code>distance</code> but avoids the square root.
//     * Use this any time the exact distance isn't exactly required.
//     * @param v1 The first Vector2 to test distance with.
//     * @param v2 The second Vector2 to test distance with.
//     * @return The resulting distance * distance between
//     *
//     */
//    public static functionVectorUtil.distanceSq (v1 :Vector2, v2 :Vector2) :Number
//    {
//        var xSep:Number = v1.x - v2.x;
//        var ySep:Number = v1.y - v2.y;
//        return ySep*ySep + xSep*xSep;
//    }
//
//    public static function distance (vector1 :Vector2, vector2 :Vector2) :Number
//    {
//        var xSep:Number = vector1.x - vector2.x;
//        var ySep:Number = vector1.y - vector2.y;
//        return Math.sqrt(ySep*ySep + xSep*xSep);
//    }





    public static function bezier (v1 :Vector2, v2 :Vector2, v3 :Vector2, t :Number,
        v :Vector2 = null) :Vector2
    {
        var fac1 :Number = Math.pow(1 - t, 2);
        var fac2 :Number = 2 * t * (1 - t);
        var fac3 :Number = Math.pow(t, 2);
        var x :Number = fac1 * v1.x + fac2 * v2.x + fac3 * v3.x;
        var y :Number = fac1 * v1.y + fac2 * v2.y + fac3 * v3.y;
        if (v == null) {
            return new Vector2(x, y);
        } else {
            v.x = x;
            v.y = y;
        }
        return v;

    }

    public static function lengthSq (v1 :Vector2) :Number
    {
        return v1.x*v1.x + v1.y*v1.y;
    }



}
}

