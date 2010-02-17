package com.threerings.util {
public class TimingUtil
{
    public static function runWhilePredicate (callback :Function, predicate :Function,
        delayFrames :int = 1, completeCallback :Function = null) :void
    {
        if (!predicate()) {
            if (completeCallback != null) {
                completeCallback();
            }
            return;
        }

        function checkAndMaybeRunAgain () :void {
            if (!predicate()) {
                if (completeCallback != null) {
                    completeCallback();
                }
            } else {
                callback();
                DelayUtil.delayFrames(delayFrames, checkAndMaybeRunAgain);
            }
        }
    }
}
}