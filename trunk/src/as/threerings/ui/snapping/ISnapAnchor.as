package com.threerings.ui.snapping {
import com.threerings.ui.bounds.Bounds;
public interface ISnapAnchor
{

    function get bounds () :Bounds;

    function getSnappableDistance (d :ISnappingObject) :Number;

    function get index () :int;

    function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean;


    function get provider () :Object;
    function get snapDistance () :Number;

    function snapObject (snappable :ISnappingObject) :void;
	
	function get userData () :*;
	function set userData (val :*) :void;
}
}
