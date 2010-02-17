package net.amago.math.geometry
{
public class NumberUtil
{
    public static function isNumberRangesIntersection(min1 :Number, max1 :Number, min2 :Number, max2 :Number) :Boolean
    {
        //If there is no intersection, return null
        if(!isNumberWithinRange(min1, min2, max2) &&
            !isNumberWithinRange(max1, min2, max2) &&
            !isNumberWithinRange(min2, min1, max1) &&
            !isNumberWithinRange(max2, min1, max1)) {
                return false;
            }
        return true;
    }

    /**
    * returns [min, max] of the intersection line.
    */
    public static function getNumberRangesIntersection(min1 :Number, max1 :Number, min2 :Number, max2 :Number) :Array
    {
        //If there is no intersection, return null
        if(!isNumberWithinRange(min1, min2, max2) &&
            !isNumberWithinRange(max1, min2, max2) &&
            !isNumberWithinRange(min2, min1, max1) &&
            !isNumberWithinRange(max2, min1, max1)) {
                return null;
            }

        //If one range is completely contained within the other, return the smaller range
        if(isNumberWithinRange(min1, min2, max2) && isNumberWithinRange(max1, min2, max2)){
            return [min1, max1];
        }
        if(isNumberWithinRange(min2, min1, max1) && isNumberWithinRange(max2, min1, max1)){
            return [min2, max2];
        }

        //Otherwise get the two intersection points
        var number1 :Number = isNumberWithinRange(min1, min2, max2) ? min1 : max1;
        var number2 :Number = isNumberWithinRange(min2, min1, max1) ? min2 : max2;

        return [ Math.min(number1, number2), Math.max(number1, number2) ];
    }

    public static function isNumberWithinRange(n :Number, low :Number, high :Number) :Boolean
    {
        return n >= low && n <= high;
    }
}
}
