package libdamago.util
{
import com.threerings.com.threerings.util.ArrayUtil;

public class SortingUtil
{
    public static function sortOnNumberFromFunction (arr :Array, valueFunc :Function) :void
    {
        var values :Array = [];
        for each (var val :Object in arr) {
            values.push([valueFunc(val), val]);
        }

        ArrayUtil.stableSort(values, function (a :Array, b :Array) :int {
           return (a[0] < b[0] ? -1 : 1);
        });

        for (var ii :int = 0; ii < arr.length; ++ii) {
            arr[ii] = values[ii][1];
        }

    }

    public static function maxValueFromFunction (arr :Array, valueFunc :Function) :Number
    {
        var value :Number = Number.MIN_VALUE;

        for each (var obj :Object in arr) {
            value = Math.max(value, valueFunc(obj));
        }

        return value;
    }

    public static function minValueFromFunction (arr :Array, valueFunc :Function) :Number
    {
        var value :Number = Number.MAX_VALUE;

        for each (var obj :Object in arr) {
            value = Math.min(value, valueFunc(obj));
        }

        return value;
    }

}
}
