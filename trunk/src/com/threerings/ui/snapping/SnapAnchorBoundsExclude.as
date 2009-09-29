package com.threerings.ui.snapping {
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.BoundsLine;
import com.threerings.ui.bounds.BoundsPoint;
import com.threerings.ui.bounds.BoundsPolygon;
import com.threerings.util.ArrayUtil;

import flash.geom.Rectangle;

import libdamago.geometry.LineSegment;
import libdamago.geometry.Polygon;
import libdamago.geometry.VectorUtil;

public class SnapAnchorBoundsExclude extends SnapAnchorBounded
{
    public function SnapAnchorBoundsExclude (globalBounds :BoundsPolygon,
        idx :int = -1, maxSnapDistance :Number = 20)
    {
        super(globalBounds, idx, maxSnapDistance);
    }

    override public function snapObject (snappable :ISnappingObject) :void
    {
        if (snappable.localBounds is BoundsPoint || snappable.localBounds is BoundsLine) {
            super.snapObject(snappable);
        }

        var translate :Vector2 = computeTranslationToMovePolygonOutside(
            BoundsPolygon(_boundsGlobal).polygon, BoundsPolygon(snappable.globalBounds).polygon);

        snappable.displayObject.x += translate.x;
        snappable.displayObject.y += translate.y;
    }


    protected static function computeTranslationToMovePolygonOutside (polyStationary :Polygon,
        moveablePoly :Polygon) :Vector2
    {
        var translation :Vector2 = new Vector2();
        var bounds1 :Rectangle = polyStationary.boundingBox;
        var bounds2 :Rectangle = moveablePoly.boundingBox;
        if (!bounds1.intersects(bounds2)) {
            return translation;
        }

        var v :Vector2;
        var ls :LineSegment;
        var ls2 :LineSegment;
        var intersectingEdge :LineSegment;
        var closestToCenterP :Vector2;
        var intersectingP :Vector2;
        var center :Vector2;
        var angle :Number;

        //If the center of moveable is inside stationary, first move the whole thing out
        center = moveablePoly.center;
        if (polyStationary.isPointInside(center) || true) {
            angle = VectorUtil.angleFromVectors(polyStationary.center, center);
            var rayFromCenter :LineSegment = new LineSegment(polyStationary.center,
                polyStationary.center.add(Vector2.fromAngle(angle,
                Math.SQRT2 * Math.max(bounds1.width, bounds1.height))));
            intersectingEdge = polyStationary.getFirstIntersectingEdge(rayFromCenter);

            var smallestEdgeDist :Number = VectorUtil.distance(
                moveablePoly.closestPointOnPerimeter(center), center);
            intersectingP = intersectingEdge.intersectionPoint(rayFromCenter);
            var locForMoveable :Vector2 = intersectingP.add(Vector2.fromAngle(angle,
                smallestEdgeDist));
            translation.addLocal(locForMoveable.subtract(center));
            moveablePoly = moveablePoly.translate(translation.x, translation.y);

        }

        //Two cases a) the stationary polygon has not vertices inside the other, b) the
        //stationary polygon has at least one vertex inside the other
        var verticesOfStationaryInside :Array = [];
        for each (v in polyStationary.vertices) {
            if (moveablePoly.isPointInside(v)) {
                verticesOfStationaryInside.push(v);
            }
        }

        var verticesOfMoveableInside :Array = [];
        for each (v in moveablePoly.vertices) {
            if (polyStationary.isPointInside(v)) {
                verticesOfMoveableInside.push(v);
            }
        }

        if (verticesOfMoveableInside.length == 1 && !polyStationary.isPointOnEdge(verticesOfMoveableInside[0])) {

            center = polyStationary.center;
            closestToCenterP = Vector2(verticesOfMoveableInside[0]);

            //Get the edge of the stationary polygon intersection the other polygon
            //Make sure it's the edge NOT intersecting through a polygon vertex.
            var allintersectingEdges :Array = [];
            var furthestDistance :Number = 0;
            intersectingEdge = null;
            for each (ls in polyStationary.edges) {
                for each (ls2 in moveablePoly.edges) {
                    if (!(ls2.a == closestToCenterP || ls2.b == closestToCenterP)) {
                        continue;
                    }
                    if (moveablePoly.isLineIntersecting(ls.a, ls.b)) {
                        var closestEndPointDistance :Number =
                            Math.min(ls.dist(ls2.a), ls.dist(ls2.b), ls2.dist(ls.a), ls2.dist(ls.b));
                        if (intersectingEdge == null) {
                            intersectingEdge = ls;
                            furthestDistance = closestEndPointDistance;
                        } else {
                            if (closestEndPointDistance > furthestDistance) {
                                intersectingEdge = ls;
                                furthestDistance = closestEndPointDistance;
                            }
                        }
                    }
                }
            }

            if (intersectingEdge != null) {
                //Now we have the point of moveable that's inside stationary
                //we get the closest point on the intersection line, which gives as
                //a direction vector to move, er, moveable


                intersectingP = intersectingEdge.closestPointTo(closestToCenterP);
                var translationAddition :Vector2 = intersectingP.subtract(closestToCenterP);
                moveablePoly = moveablePoly.translate(translationAddition.x, translationAddition.y);
                translation = translation.add(translationAddition);


            }
        }
        else
        if (verticesOfStationaryInside.length == 1 && !moveablePoly.isPointOnEdge(verticesOfStationaryInside[0])) {

            center = moveablePoly.center;
            ArrayUtil.stableSort(verticesOfStationaryInside,
                function (v1 :Vector2, v2 :Vector2) :int {
                    return VectorUtil.distanceSq(center, v1) <
                        VectorUtil.distanceSq(center, v2) ? -1 : 1;
                });
            closestToCenterP = Vector2(verticesOfStationaryInside[0]);

            for each (ls in moveablePoly.edges) {
                for each (ls2 in polyStationary.edges) {
                    if (!(ls2.a == closestToCenterP || ls2.b == closestToCenterP)) {
                        continue;
                    }

                    intersectingP = ls.intersectionPoint(ls2);

                    if (intersectingP == ls.a || intersectingP == ls.b) {
                        continue;
                    }
                    if (polyStationary.isLineIntersecting(ls.a, ls.b)) {
                        intersectingEdge = ls;
                        break;
                    }
                }
            }

            if (intersectingEdge != null) {
                //Now we have the point of moveable that's inside stationary
                //we get the closest point on the intersection line, which gives as
                //a direction vector to move, er, moveable


                intersectingP = intersectingEdge.closestPointTo(closestToCenterP);
                translation = translation.add(intersectingP.subtract(closestToCenterP).scale(-1));

            }
        }
        else if (verticesOfMoveableInside.length > 1) {

            var closestStationaryEdgeToCenter :LineSegment = polyStationary.closestEdge(
                moveablePoly.center);
            center = moveablePoly.center;
            var smallestDistance :Number = Number.MAX_VALUE;
            var distance :Number;
            var closestLine :LineSegment;
            for each (var line :LineSegment in polyStationary.edges) {
                distance = line.dist(center);
                var closestPoint :Vector2 = new Vector2();
                if (distance < smallestDistance) {
                    smallestDistance = distance;
                    closestLine = line;
                } else if (distance == smallestDistance) {//edge case
                    //Make sure it's the perpendicular one
                    //...extend the closest point along the edge
                    var curMidP :Vector2 = closestLine.midpoint;
                    v = closestLine.closestPointTo(center);
                    v = v.add(Vector2.fromAngle(VectorUtil.angleFromVectors(v, curMidP), 1));
                    var distCurrent :Number = VectorUtil.distanceSq(v, center);

                    var otherMidP :Vector2 = line.midpoint;
                    v = line.closestPointTo(center);
                    v = v.add(Vector2.fromAngle(VectorUtil.angleFromVectors(v, otherMidP), 1));
                    var distOther :Number = VectorUtil.distanceSq(v, center);

                    if (distOther < distCurrent) {
                        smallestDistance = distance;
                        closestLine = line;
                    }

                }
            }

            //Get the furthest distance
            var distanceToShove :Number = 0;
            verticesOfMoveableInside.forEach(function (v :Vector2, ...ignored) :void {
                distance = closestLine.dist(v);
                if (distance > distanceToShove) {
                    distanceToShove = distance;
                }
            });
            var angleToShove :Number = VectorUtil.angleFromVectors(
                closestLine.closestPointTo(center), center);
            translation = translation.add(Vector2.fromAngle(angleToShove, distance));

        }
        return translation;
    }

}
}