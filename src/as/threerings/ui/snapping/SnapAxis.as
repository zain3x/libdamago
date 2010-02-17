//
// $Id$

package com.threerings.ui.snapping{

import com.threerings.util.Enum;

/**
 * SnapType enum.
 */
public final class SnapAxis extends Enum
{
    // DEFINE MEMBERS HERE
    public static const X :SnapAxis = new SnapAxis("X");
    public static const Y :SnapAxis = new SnapAxis("Y");
    public static const X_AND_Y :SnapAxis = new SnapAxis("X_AND_Y");
    finishedEnumerating(SnapAxis);

    /**
     * Get the values of the SnapType enum
     */
    public static function values () :Array
    {
        return Enum.values(SnapAxis);
    }

    /**
     * Get the value of the SnapType enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :SnapAxis
    {
        return Enum.valueOf(SnapAxis, name) as SnapAxis;
    }

    /** @private */
    public function SnapAxis (name :String)
    {
        super(name);
    }
}
}
