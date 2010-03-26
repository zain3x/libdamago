package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;

import flash.display.DisplayObject;
import flash.events.IEventDispatcher;
import flash.geom.Point;

public interface ISnappingObject
{
    function get displayObject () :DisplayObject;

    function get globalBounds () :Bounds; //Global bounds
    function get localBounds () :Bounds; //Local bounds

    function get x () :Number;
    function set x (val :Number) :void;
    
    function get y () :Number;
    function set y (val :Number) :void;

    function beginSnapping (snapManager :IEventDispatcher) :void;
    function endSnapping (anc :ISnapAnchor = null) :void;

    function snapCenterToGlobal (p :Point) :void;
    
    /**
     * Called after a snap anchor snaps this object
     */
//    function snapped (anchor :ISnapAnchor) :void;
    
    /**
     * Called on frames where there was no snap anchor in range.
     */
//    function notSnapped () :void;
}
}
