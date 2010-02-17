package com.threerings.util {
import com.threerings.util.ReflectionUtil;

public class LogUtil
{
    /**
     *
     * This doesn't work but it should
     * http://www.kirupa.com/forum/showthread.php?t=196330
     * Usage (within a class function):
     *  trace(LogUtil.functionName(arguments.callee, this));
     *
     *
     */
    public static function functionName (func :Function, clazzObj :Object) :String
    {

        //        ReflectionUtil.getAccessorNames(
        //        for (var a :String in clazzObj) {
        //            if (func == clazzObj[a]) {
        //                return a;
        //            }
        //        }
        return null;
    }
}
}
