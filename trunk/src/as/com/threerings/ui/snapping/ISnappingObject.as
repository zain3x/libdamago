package com.threerings.ui.snapping {
import flash.display.DisplayObject;
import flash.geom.Point;
import com.threerings.ui.bounds.Bounds;

public interface ISnappingObject
{
    function get displayObject () :DisplayObject;

    function get globalBounds () :Bounds; //Global bounds
    function get localBounds () :Bounds; //Local bounds

    function get x () :Number;
    function set x (val :Number) :void;
    
    function get y () :Number;
    function set y (val :Number) :void;

    function beginSnapping () :void;
    function endSnapping (anc :ISnapAnchor = null) :void;

    function snapCenterToGlobal (p :Point) :void;
    function snapped (anchor :ISnapAnchor) :void;
}
}
