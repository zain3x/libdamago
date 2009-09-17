package com.threerings.ui.snapping {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

public interface ISnapAnchor
{
    function get displayObject () :DisplayObject;

    function get displayContainer () :DisplayObjectContainer;

    function getSnappableDistance (d :ISnappingObject) :Number;

    function isSnappable (snappable :ISnappingObject) :Boolean;

    function isWithinSnappingDistance (snappable :ISnappingObject) :Boolean;

    function snapObject (snappable :ISnappingObject) :void;

}
}