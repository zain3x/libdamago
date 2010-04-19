package net.amago.util {
import com.threerings.util.Map;
public class ArrayMappings
{
    public static function createFieldMapping (fieldName :String) :Function
    {
        return function (obj :Object, ... _) :* {
            return obj[fieldName];
        }
    }

    public static function createIndexMap (items :Array, map :Map) :void
    {
        for (var ii :int = 0; ii < items.length; ++ii) {
            map.put(ii, items[ii]);
        }
    }

    public static function toIndex (item :*, index :int, array :Array) :int
    {
        return index;
    }
}
}