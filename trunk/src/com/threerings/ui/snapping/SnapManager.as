//
// $Id$

package com.threerings.ui.snapping
{
import com.whirled.contrib.EventHandlerManager;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;
import flash.geom.Rectangle;
/**
 * Adds "snapping" to display objects when close enough to snap anchors.
 *
 * Usage:
 * var snapManager :SnapManager = new SnapManager(someRootLayerSprite);
 * snapManager.addPointAnchor(holeGraphic);
 * snapManager.addRectAnchor(someOtherGraphic);
 * <br/>
 * //When the user creates an object that can snap into the anchors
 * snapManager.addSnappable(someSprite);
 * <br/>
 * When you don't want the object snapping anymore, use
 * snapManager.removeSnappable(someSprite);
 * <br/>
 * That's it.
 *
 */
[Event(name="snapEvent", type="com.threerings.ui.snapping.SnapEvent")]
public class SnapManager extends EventDispatcher
{

    public function SnapManager (parent :Sprite)
    {
        _parent = parent;
    }

    public function shutdown () :void
    {
        clear();
        _parent = null;
    }

    public function clear () :void
    {
        endSnapping();
        _mouseDownEvents.freeAllHandlers();
        _events.freeAllHandlers();
        _snapAnchors = [];
        _target = null;
    }

    public function addAnchor (anchor :ISnapAnchor) :void
    {
        _snapAnchors.push(anchor);
    }

    public function beginSnapping (snapper :ISnappingObject) :void
    {
        if (_target != null) {
            endSnapping(_target);
        }
        _target = snapper;
        _events.registerListener(_parent, Event.ENTER_FRAME, handleEnterFrame);

        if (DEBUG_DRAW) {
            _debugLayer.graphics.clear();
            _parent.addChildAt(_debugLayer, _parent.numChildren);
            for each (var anc :SnapAnchorBounded in _snapAnchors) {
                if (anc == null) {
                    continue;
                }
                anc._boundsGlobal.debugDraw(_debugLayer.graphics);
            }
        }
    }

    public function endSnapping (snapper :ISnappingObject = null) :void
    {
        _events.freeAllHandlers();
        _target = null;
        _debugLayer.graphics.clear();
    }

    protected function getClosestAnchorToTarget () :ISnapAnchor
    {
        if (_target == null) {
            return null;
        }
        var closestAnchor :ISnapAnchor = null;
        var closestDistance :Number = Number.MAX_VALUE;
        var distance :Number;

        for each (var anchor :ISnapAnchor in _snapAnchors) {
            distance = anchor.getSnappableDistance(_target);
            trace(anchor + " distance=" + distance);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestAnchor = anchor;
            }
        }
        return closestAnchor;
    }

    protected function handleEnterFrame (...ignored) :void
    {
        if (_target == null) {
            return;
        }

        var stage :DisplayObject = _target.displayObject.stage;
        //First move it to the mouse coords
        var globalMouseLoc :Point = _target.displayObject.localToGlobal(
            new Point(_target.displayObject.mouseX, _target.displayObject.mouseY));


        var boundsLoc :Rectangle = _target.boundsDisplayObject.getBounds(stage);
        var centerX :Number = boundsLoc.left + boundsLoc.width / 2;
        var centerY :Number = boundsLoc.top + boundsLoc.height / 2;

        _target.displayObject.x += globalMouseLoc.x - centerX;
        _target.displayObject.y += globalMouseLoc.y - centerY;

        //Snap to all anchors close enough
        var snapped :Boolean = false;
        for each (var anc :ISnapAnchor in _snapAnchors) {
            if (anc.isWithinSnappingDistance(_target)) {
                anc.snapObject(_target);
                //Dispatch event whether we snap or not to indicate snapping/no snapping
                dispatchEvent(new SnapEvent(anc, _target));
                snapped = true;
            }
        }

        //If nothing is snapped, inform listeners of this
        if (!snapped) {
            dispatchEvent(new SnapEvent(null, _target));
        }
    }

    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _mouseDownEvents :EventHandlerManager = new EventHandlerManager();

    protected var _parent :Sprite;
    protected var _snapAnchors :Array = [];
    protected var _target :ISnappingObject;

    public static const DEBUG_DRAW :Boolean = true;
    protected var _debugLayer :Sprite = new Sprite();
}
}