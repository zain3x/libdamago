//
// $Id$

package com.threerings.ui
{

import com.threerings.util.Enum;

/**
 * OrientationType enum.
 */
public final class OrientationType extends Enum
{
    public static const HORIZONTAL :OrientationType = new OrientationType("HORIZONTAL");
    public static const VERTICAL :OrientationType = new OrientationType("VERTICAL");
    finishedEnumerating(OrientationType);

    /**
     * Get the values of the OrientationType enum
     */
    public static function values () :Array
    {
        return Enum.values(OrientationType);
    }

    /**
     * Get the value of the OrientationType enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :OrientationType
    {
        return Enum.valueOf(OrientationType, name) as OrientationType;
    }

    /** @private */
    public function OrientationType (name :String)
    {
        super(name);
    }
}
}
