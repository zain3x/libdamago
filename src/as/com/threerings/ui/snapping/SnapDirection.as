//
// $Id$

package com.threerings.ui.snapping {
import com.threerings.util.Enum;

/**
 * SnapType enum.
 */
public final class SnapDirection extends Enum
{
    public static const BOTTOM :SnapDirection = new SnapDirection("BOTTOM");
    public static const LEFT :SnapDirection = new SnapDirection("LEFT");
    public static const RIGHT :SnapDirection = new SnapDirection("RIGHT");
    public static const TOP :SnapDirection = new SnapDirection("TOP");
    public static const X :SnapDirection = new SnapDirection("X");
    public static const X_AND_Y :SnapDirection = new SnapDirection("X_AND_Y");
    public static const Y :SnapDirection = new SnapDirection("Y");

    /**
     * Get the value of the SnapType enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :SnapDirection
    {
        return Enum.valueOf(SnapDirection, name) as SnapDirection;
    }

    /**
     * Get the values of the SnapType enum
     */
    public static function values () :Array
    {
        return Enum.values(SnapDirection);
    }

    /** @private */
    public function SnapDirection (name :String)
    {
        super(name);
    }
    finishedEnumerating(SnapDirection);
}
}
