//
// $Id$

package com.threerings.ui.snapping{

import com.threerings.util.Enum;

/**
 * SnapType enum.
 */
public final class SnapType extends Enum
{
    // DEFINE MEMBERS HERE
    public static const POINT :SnapType = new SnapType("POINT");
    public static const BORDER :SnapType = new SnapType("BORDER");
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
