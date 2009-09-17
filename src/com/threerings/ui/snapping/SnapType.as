//
// $Id$

package com.threerings.ui.snapping {

import com.threerings.util.Enum;

/**
 * SnapType enum.
 */
public final class SnapType extends Enum
{
    public static const FIXED :SnapType = new SnapType("FIXED");
    public static const SLIDING :SnapType = new SnapType("SLIDING");
    finishedEnumerating(SnapType);

    /**
     * Get the values of the SnapType enum
     */
    public static function values () :Array
    {
        return Enum.values(SnapType);
    }

    /**
     * Get the value of the SnapType enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :SnapType
    {
        return Enum.valueOf(SnapType, name) as SnapType;
    }

    /** @private */
    public function SnapType (name :String)
    {
        super(name);
    }
}
}
