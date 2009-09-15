package com.threerings.ui.blockeditor
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import com.threerings.ui.snapping.SnapManager;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ValueEvent;

public class BlockEditor extends Sprite
{
    public function BlockEditor (allowedAnchors :Function)
    {
        _allowedAnchorsFunction = allowedAnchors;
        _snapManager = new SnapManager(this, _allowedAnchorsFunction);
    }

    protected function handleAddedToAnchor (e :ValueEvent) :void
    {
        var obj :DisplayObject = e.value[0] as DisplayObject;
        var anchor :DisplayObject = e.value[1] as DisplayObject;
    }

    protected var _allowedAnchorsFunction :Function;
    protected var _anchorMap :Map = Maps.newMapOf(DisplayObject);
    protected var _snapManager :SnapManager;
}
}