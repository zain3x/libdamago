//
// $Id$

package com.threerings.ui.snapping {

import com.threerings.util.Enum;

/**
 * SnapType enum.
 */
public final class SnapType extends Enum
{
    public static const NULL :SnapType = new SnapType("NULL");
    public static const CENTER :SnapType = new SnapType("CENTER");
    public static const PERIMETER_OUTER :SnapType = new SnapType("PERIMETER_OUTER");
    public static const PERIMETER_INNER :SnapType = new SnapType("PERIMETER_INNER");
    public static const PERIMETER_CENTERED :SnapType = new SnapType("PERIMETER_CENTERED");
    public static const LINE :SnapType = new SnapType("LINE");
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
