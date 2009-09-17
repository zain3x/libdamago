package com.threerings.ui.snapping {
import flash.display.DisplayObject;

public interface ISnappingObject
{
    function get boundsDisplayObject () :DisplayObject;

    function get displayObject () :DisplayObject;
}
}