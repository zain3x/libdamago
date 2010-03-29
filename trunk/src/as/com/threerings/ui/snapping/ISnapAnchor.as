package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;

import flash.display.DisplayObject;

public interface ISnapAnchor
{
    function get bounds () :Bounds;
    function get index () :int;

    function get provider () :Object;
    function get snapDistance () :Number;

    function get userData () :*;
    function set userData (val :*) :void;
    
    /**
     * For showing the snap anchors graphically.
     * If there is a displayObject it will be added/removed to the editor layer on 
     * snapping begin/end. 
     */
    function get displayObject () :DisplayObject;

    function getSnappableDistance (d :ISnappingObject) :Number;
    function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean;
    function snapObject (snappable :ISnappingObject) :void;
}
}
