//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.display.DisplayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.whirled.contrib.EventHandlerManager;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.MouseEvent;
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

//    public function addPointAnchor (d :DisplayObjectContainer) :void
//    {
//        addAnchor(new SnapAnchorPoint(d));
//    }
//
//    public function addRectAnchor (d :DisplayObjectContainer) :void
//    {
//        addAnchor(new SnapAnchorRect(d, SnapAxis.X_AND_Y));
//    }

    public function addSnappable (snappable :ISnappingObject) :void
    {
//        var snappable :SnappingObject = new SnappingObject(boundsObj, rootLayer);
        _mouseDownEvents.registerListener(snappable.displayObject, MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                beginSnapping(snappable);
            });
//        _snappableObjects.put(snappable, null);
    }

    public function removeSnappable (snappable :ISnappingObject) :void
    {
        _mouseDownEvents.freeAllOn(snappable.boundsDisplayObject);
        if (_target == snappable) {
            endSnapping();
        }
//        _snappableObjects.remove(snappable);
    }

    public function shutdown () :void
    {
        clear();
        _parent = null;
    }

    public function clear () :void
    {
        _mouseDownEvents.freeAllHandlers();
        _events.freeAllHandlers();
        _snapAnchors = [];
        _target = null;
//        _snappableObjects.clear();
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

    }

    public function endSnapping (snapper :ISnappingObject = null) :void
    {
        _events.freeAllHandlers();
        _target = null;
    }

    protected function getClosestAnchorToTarget () :ISnapAnchor
    {
        if (_target == null) {
            return null;
        }
        var closestAnchor :ISnapAnchor = null;
        var closestDistance :Number = Number.MAX_VALUE;
        var distance :Number;
        var allowedAnchors :Array = _snapAnchors;
//        if (_allowedAnchorsFunction != null) {
//            var allowedAnchorDisplayObjects :Array = _allowedAnchorsFunction(_target.boundsDisplay);
//            allowedAnchors = allowedAnchors.filter(
//                function (anchor :ISnapAnchor, ...ignored) :Boolean {
//                    return ArrayUtil.contains(allowedAnchorDisplayObjects, anchor.displayObject);
//                });
//        }

        for each (var anchor :ISnapAnchor in _snapAnchors) {
            distance = anchor.getSnappableDistance(_target);
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

        //Then maybe snap, if a snap anchor is close enough.
        var closestAnchor :ISnapAnchor = getClosestAnchorToTarget();
        if (closestAnchor == null || !closestAnchor.isWithinSnappingDistance(_target)) {
            _currentSnapAnchor = null;
            return;
        }

        closestAnchor.snapObject(_target);
        dispatchEvent(new SnapEvent(closestAnchor, _target));
    }

    protected var _currentSnapAnchor :ISnapAnchor;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _mouseDownEvents :EventHandlerManager = new EventHandlerManager();

    protected var _parent :Sprite;
    protected var _snapAnchors :Array = [];
//    protected var _snappableObjects :Map = Maps.newMapOf(DisplayObject);
    protected var _target :ISnappingObject;
}
}