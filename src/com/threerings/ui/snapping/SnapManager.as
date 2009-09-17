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

    public function addPointAnchor (d :DisplayObjectContainer) :void
    {
        addAnchor(new SnapAnchorPoint(d));
    }

    public function addRectAnchor (d :DisplayObjectContainer) :void
    {
        addAnchor(new SnapAnchorRect(d, SnapAxis.X_AND_Y));
    }

    public function addSnappable (snappable :ISnappingObject) :void
    {
//        var snappable :SnappingObject = new SnappingObject(boundsObj, rootLayer);
        _mouseDownEvents.registerListener(snappable.displayObject, MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                beginSnapping(snappable);
            });
        _snappableObjects.put(snappable, null);
    }

    public function removeSnappable (snappable :ISnappingObject) :void
    {
        _mouseDownEvents.freeAllOn(snappable.boundsDisplayObject);
        if (_target == snappable) {
            endSnapping();
        }
        _snappableObjects.remove(snappable);
    }

    public function shutdown () :void
    {
        _mouseDownEvents.freeAllHandlers();
        _events.freeAllHandlers();
        _snapAnchors = [];
        _parent = null;
        _target = null;
    }

    public function addAnchor (anchor :ISnapAnchor) :void
    {
        _snapAnchors.push(anchor);
    }

    protected function beginSnapping (snapper :ISnappingObject) :void
    {
        if (_target != null) {
            endSnapping(_target);
        }
        _target = snapper;
        _events.registerListener(_parent, Event.ENTER_FRAME, handleEnterFrame);
        _events.registerListener(snapper.displayObject, MouseEvent.MOUSE_UP,
            function (...ignored) :void {
                endSnapping(snapper);
            });
    }

    protected function endSnapping (snapper :ISnappingObject = null) :void
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

        //First move it to the mouse coords
        var parentMousePoint :Point = DisplayUtil.transformPoint(
            new Point(_target.displayObject.mouseX, _target.displayObject.mouseY), _target.displayObject, _parent);
        _target.displayObject.x = parentMousePoint.x;
        _target.displayObject.y = parentMousePoint.y;

        //Then maybe snap, if a snap anchor is close enough.
        var closestAnchor :ISnapAnchor = getClosestAnchorToTarget();
        if (closestAnchor == null || !closestAnchor.isWithinSnappingDistance(_target)) {
            _currentSnapAnchor = null;
            return;
        }

        closestAnchor.snapObject(_target)

//        var snapPoint :Point = closestAnchor.getSnapToPoint(_target);
//        snapToPoint(_target, snapPoint, closestAnchor);
//        _currentSnapAnchor = closestAnchor;

    }

//    /**
//     * Fire an event when the object is snapped to the anchor.
//     */
//    protected function snapToPoint (snapper :SnappingObject, p :Point, anchor :SnapAnchor) :void
//    {
//        var d :DisplayObject = snapper.rootLayer;
//        if (d.x != p.x && d.y != p.y) {
//            dispatchEvent(new SnapEvent(SnapAxis.X_AND_Y, anchor.dataObj, snapper.dataObj));
//        }
//
//        snapper.snapCenterOfBoundsToPoint(p);
//    }

    protected var _currentSnapAnchor :ISnapAnchor;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _mouseDownEvents :EventHandlerManager = new EventHandlerManager();

    protected var _parent :Sprite;
    protected var _snapAnchors :Array = [];
    protected var _snappableObjects :Map = Maps.newMapOf(DisplayObject);
    protected var _target :ISnappingObject;
}
}