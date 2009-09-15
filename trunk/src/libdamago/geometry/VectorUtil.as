package libdamago.geometry
{
import com.threerings.geom.Vector2;
import com.threerings.util.Log;
import com.threerings.util.MathUtil;
import com.threerings.util.Set;
import com.threerings.util.Sets;

import flash.geom.Rectangle;

public class VectorUtil
{
    //Multiply by these numbers to get your result.
    //EG: angleInRadians = 30 * DEG_TO_RAD;
    public static const RAD_TO_DEG:Number = (180 / Math.PI); //57.29577951;
    public static const DEG_TO_RAD:Number = (Math.PI / 180); //0.017453293;
    public static const ZERO :Vector2 = new Vector2(); //0.017453293;

    public static function distance (v1 :Vector2, v2 :Vector2) :Number
    {
         return MathUtil.distance(v1.x, v1.y, v2.x, v2.y);
    }

    public static function addLocalPolarVector (v :Vector2, rad :Number, length :Number) :Vector2
    {
        var polar :Vector2 = Vector2.fromAngle(rad, length);
        v.addLocal(polar);
        return v;
    }

    /**
     * Returns the angle (radians) from v1 to v2.
     */
    public static function angleFromVectors (v1 :Vector2, v2 :Vector2) :Number
    {
        return angleFrom(v1.x, v1.y, v2.x, v2.y);
    }

    public static function angleFrom (x1 :Number, y1 :Number, x2 :Number, y2 :Number) :Number
    {
        var angle :Number = Math.atan2(y2 - y1, x2 - x1);
        return (angle >= 0 ? angle : angle + (2 * Math.PI));
    }

     //Returns the angle between two points
     public static function calcAngle (p1:Vector2, p2:Vector2) :Number
     {
         var angle:Number = Math.atan((p2.y - p1.y) / (p2.x - p1.x)) * RAD_TO_DEG;

         //if it is in the first quadrant
         if(p2.y < p1.y && p2.x > p1.x)
         {
             return angle;
         }
         //if its in the 2nd or 3rd quadrant
         if((p2.y < p1.y && p2.x < p1.x) || (p2.y > p1.y && p2.x < p1.x))
            {
                return angle + 180;
            }
         //it must be in the 4th quadrant so:
         return angle + 360;
     }

          //origin means original starting radian, dest destination radian around a circle
    /**
     * Determines which direction a point should rotate to match rotation the quickest
     * @param objectRotationRadians The object you would like to rotate
     * @param radianBetween the angle from the object to the point you want to rotate to
     * @return -1 if left, 0 if facing, 1 if right
     *
     */
    public static function getSmallestRotationDirection(objectRotationRadians:Number,
        radianBetween:Number, errorRadians:Number = 0):int
    {
        objectRotationRadians = simplifyRadian(objectRotationRadians);
        radianBetween = simplifyRadian(radianBetween);

        radianBetween += -objectRotationRadians;
        radianBetween = simplifyRadian(radianBetween);
        objectRotationRadians = 0;
        if(radianBetween < -errorRadians)
        {
            return -1;
        }
        else if(radianBetween > errorRadians)
        {
            return 1;
        }
        return 0;
    }

    public static function simplifyRadian (radian :Number) :Number
    {
        if(radian > Math.PI || radian < -Math.PI)
        {
            var newRadian:Number;
            newRadian = radian - int(radian / (Math.PI *2)) * (Math.PI * 2);
            if(radian > 0)
            {
                if(newRadian < Math.PI)
                {
                    return newRadian;
                }
                else
                {
                    newRadian =- (Math.PI * 2 - newRadian);
                    return newRadian;
                }
            }
            else
            {
                if(newRadian > -Math.PI)
                {
                    return newRadian;
                }
                else
                {
                    newRadian = ((Math.PI * 2) + newRadian);
                    return newRadian;
                }
            }
        }
        return radian;
    }

    public static function distanceSq (a :Vector2, b :Vector2) :Number
    {
        return  (a.x - b.x)*(a.x - b.x) + (a.y - b.y)*(a.y - b.y);
    }

    /**
     * The smallest difference between two angles with the right sign and clamped (-Pi, Pi)
     */
    public static function differenceAngles (angle1 :Number, angle2 :Number) :Number
    {
        var diff :Number = angle1 - angle2;
        if( diff > Math.PI) {
            diff = -2 * Math.PI + diff;
        }
        if( diff < -Math.PI) {
            diff = 2 * Math.PI + diff;
        }
        return -diff;
    }

    /**
     * @initialLocations : an Array of Vector2 objects.
     * @initialAngle : the angle from the center of the locations in which the sweep starts.
     * @radiusFunction : takes a Vector2 and returns a radius. Must be > 0.  Small values mean
     *                   smaller sweep intervals and thus longer computation time.
     */
    public static function sortVectorsBySweep (initialLocations :Array, initialAngle :Number,
        radiusFunction :Function) :Array
    {
        var v :Vector2;
        var bounds :Rectangle = new Polygon(Polygon.convexHullFromPoints(initialLocations)).boundingBox;
        var maxFormationRadius :Number = Math.max(bounds.width, bounds.height) * Math.SQRT2;

        var center :Vector2 = new Vector2(bounds.x + bounds.width / 2,
                                            bounds.y + bounds.height / 2);


        var smallestRadius :Number = Number.MAX_VALUE;
        initialLocations.forEach(function (v :Vector2, ...ignored) :void {
            var radius :Number = radiusFunction(v) as Number;
            if (radius < smallestRadius) {
                smallestRadius = radius;
            }
        });

        //Starting from in front of the front-most unit, move a line backwards.  As the units
        //touch the line, they are added to the squad in that order.  Thus, it gives a
        //order from front to back.
        var radiusForComputingSqadOrder :Number = Math.max(bounds.width, bounds.height) * Math.SQRT2/2;
        var normalP1 :Vector2 = Vector2.fromAngle(initialAngle + Math.PI/4, radiusForComputingSqadOrder);
        normalP1.addLocal(center);
        var normalP2 :Vector2 = Vector2.fromAngle(initialAngle - Math.PI/4, radiusForComputingSqadOrder);
        normalP2.addLocal(center);
        //The normal line segment is incremented by the transform.
        var normalTransformIncrement :Vector2 = Vector2.fromAngle(initialAngle, -1);
        //This should be really small in case there are +1 units on the first pass.
        var incrementLength :Number = smallestRadius / 4;
        normalTransformIncrement.scaleLocal(incrementLength);

        //The distance the line has moved.
        var totalNormalLineSegmentTransformed :Number = 0;
        var unitsPlacedInFormation :Set = Sets.newSetOf(Vector2);//Don't check these locations anymore

        var orderOfUnitsInFormation :Array = new Array();//The order in which to place units in formation

        //Move the line backwards until it hits the rear bounds.
        while (totalNormalLineSegmentTransformed < radiusForComputingSqadOrder * 2 &&
            orderOfUnitsInFormation.length < initialLocations.length) {

            //Increment the line
            normalP1.addLocal(normalTransformIncrement);
            normalP2.addLocal(normalTransformIncrement);
            totalNormalLineSegmentTransformed += incrementLength;

            //Check all units whether they intersect the line
            //If >1 units are found in a single pass, order them by proximity to the center
            var unitsFoundThisPass :Array = [];
            for each (v in initialLocations) {
                //Ingore units we have already placed
                if (unitsPlacedInFormation.contains(v)) {
                    continue;
                }
                //If the circle for the unit overlaps the moving line, add it to the order
                if (Geometry.isCircleOverlappingSegment(normalP1, normalP2, v, radiusFunction(v))) {
                    unitsFoundThisPass.push(v);
                }
            }
            if (unitsFoundThisPass.length == 1) {
                orderOfUnitsInFormation.push(unitsFoundThisPass[0]);
                unitsPlacedInFormation.add(unitsFoundThisPass[0]);
            }
            //Ok more than one unit found.  Order them by proximty to the center
            else if (unitsFoundThisPass.length > 1) {
                //Sort
                unitsFoundThisPass.sort(function compareFunction (vecA :Vector2, vecB :Vector2) :int {

                    var distA :Number = VectorUtil.distanceSq(vecA, center);
                    var distB :Number = VectorUtil.distanceSq(vecB, center);
                    if (distA < distB) {
                        return -1;
                    }
                    else if (distA > distB) {
                        return 1;
                    }
                    return 0;
                });
                //Now add them
                for each (var sortedUnit :Vector2 in unitsFoundThisPass) {
                    orderOfUnitsInFormation.push(sortedUnit);
                    unitsPlacedInFormation.add(sortedUnit);
                }
            }
        }


        if (orderOfUnitsInFormation.length == 0) {
            log.error("orderOfUnitsInFormation.length == 0, meaning the position scanner failed to scan the units of squad ");
            log.error("initialLocations=" + initialLocations);
        }
        return orderOfUnitsInFormation;
    }

    protected static const log :Log = Log.getLog(VectorUtil);
}
}
