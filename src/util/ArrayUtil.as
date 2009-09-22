package util {
    import aduros.util.F;

public class ArrayUtil
{
    public static function uniqueElements (arr :Array, compare :Function  = null) :Array
    {
        compare = (compare != null ? compare : function (e1 :Object, e2 :Object) :Boolean {
            return e1 == e2;
        });
        var unique :Array = [];
        for each (var e :Object in arr) {
            var duplicate :Boolean = false;
            for each (var e2 :Object in unique) {
                if (compare(e, e2)) {
                    duplicate = true;
                    break;
                }
            }
            if (!duplicate) {
                unique.push(e);
            }
        }
        arr.splice(0);
        unique.forEach(function (e :Object, ...ignored) :void {
            arr.push(e);
        });
        return unique;
    }

}
}