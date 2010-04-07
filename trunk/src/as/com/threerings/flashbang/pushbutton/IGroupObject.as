package com.threerings.flashbang.pushbutton
{

/**
 * Marker interface for creating ObjectDB groups..
 */
public interface IGroupObject
{

    /**
     * The results of this call must never change over the life of the object,
     * or else there will be references to the object and thus it won't be gc'ed.
     * @return List of group names.
     */
    function get groupNames () :Array;//<String>
}
}