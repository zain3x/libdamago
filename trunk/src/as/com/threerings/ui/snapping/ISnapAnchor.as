package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
public interface ISnapAnchor
{
    function get bounds () :Bounds;
    function get index () :int;

    function get provider () :Object;
    function get snapDistance () :Number;

    function get userData () :*;
    function set userData (val :*) :void;

    function getSnappableDistance (d :ISnappingObject) :Number;
    function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean;
    function snapObject (snappable :ISnappingObject) :void;
}
}
