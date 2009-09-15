package util
{
    import com.threerings.geom.Vector2;


public class GameUtil
{
    public static function getStringHash (val :String) :int
    {
        // examine at most 32 characters of the val
        var hash :int;
        var inc :int = int(Math.max(1, Math.ceil(val.length / 32)));
        for (var ii :int = 0; ii < val.length; ii += inc) {
            // hash(i) = (hash(i-1) * 33) ^ str[i]
            hash = ((hash << 5) + hash) ^ int(val.charCodeAt(ii));
        }

        return hash;
    }



    /**
     * Returns true if the components of v are equal to the components of this Vector2,
     * within the given epsilon.
     */
    public static function similar (x1 :Number, x2 :Number, epsilon :Number) :Boolean
    {
        return Math.abs(x1 - x2) <= epsilon ;
    }


    /**
    * We assume that the board will not have more than 10000 units.  So a somewhat unique
    * id for a pair of units can be created by multipling the larger number by 100000 and
    * adding it to the smaller number.
    */
    public static function hashForIdPair (id1 :int, id2 :int, maxid :int = 10000) :int
    {
        return Math.max(id1, id2) * maxid + Math.min(id1, id2);
    }

}
}
