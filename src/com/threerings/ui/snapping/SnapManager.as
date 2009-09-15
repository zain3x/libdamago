package com.threerings.ui.snapping
{
import aduros.util.F;

import com.threerings.display.DisplayUtil;
import com.threerings.util.ArrayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.ValueEvent;
import com.whirled.contrib.EventHandlerManager;

import flash.display.DisplayObject;
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
 *
 * //When the user creates an object that can snap into the anchors
 * snapManager.addSnappable(someSprite);
 *
 * That's it.
 *
 */
public class SnapManager extends EventDispatcher
{
    public static const EVENT_OBJECT_SNAPPED :String = "objectSnapped";
    public static const EVENT_OBJECT_SNAPPING_REMOVED :String = "objectSnappingRemoved";

    public function SnapManager (parent :Sprite, allowedAnchors :Function = null)
    {
        _parent = parent;
        _allowedAnchorsFunction = allowedAnchors;
    }

    public function addSnappable (boundsObj :DisplayObject, rootLayer :DisplayObject = null) :void
    {
        var snappable :SnappingObject = new SnappingObject(boundsObj, rootLayer);
        _mouseDownEvents.registerListener(snappable.rootLayer, MouseEvent.MOUSE_DOWN,
            function (...ignored) :void {
                beginSnapping(snappable);
            });
        _snappableObjects.put(boundsObj, snappable);
    }

    public function removeSnappable (boundsObj :DisplayObject) :void
    {
        _mouseDownEvents.freeAllOn(boundsObj);
        if (_target.boundsDisplay == boundsObj) {
            endSnapping();
        }
        _snappableObjects.remove(boundsObj);
        dispatchEvent(new ValueEvent(EVENT_OBJECT_SNAPPING_REMOVED, boundsObj));
    }

    public function addPointAnchor (d :DisplayObject) :void
    {
        addAnchor(new SnapAnchorPoint(d, _parent));
    }

    public function addRectAnchor (d :DisplayObject, snapAxis :SnapAxis) :void
    {
        addAnchor(new SnapAnchorRect(d, _parent, snapAxis));
    }

    public function shutdown () :void
    {
        _mouseDownEvents.freeAllHandlers();
        _events.freeAllHandlers();
        _snapAnchors = [];
        _parent = null;
        _target = null;
    }

    protected function addAnchor (anchor :SnapAnchor) :void
    {
        _snapAnchors.push(anchor);
    }

    protected function beginSnapping (snapper :SnappingObject) :void
    {
        if (_target != null) {
            endSnapping(_target);
        }
        _target = snapper;
        _events.registerListener(_parent, Event.ENTER_FRAME, handleEnterFrame);
        _events.registerListener(snapper.rootLayer, MouseEvent.MOUSE_UP, F.callback(endSnapping, snapper));
    }

    protected function endSnapping (snapper :SnappingObject = null) :void
    {
        _events.freeAllHandlers();
        _target = null;
    }

    protected function handleEnterFrame (...ignored) :void
    {
        if (_target == null) {
            return;
        }

        //First move it to the mouse coords
        var parentMousePoint :Point = DisplayUtil.transformPoint(
            new Point(_target.rootLayer.mouseX, _target.rootLayer.mouseY), _target.rootLayer, _parent);
        _target.rootLayer.x = parentMousePoint.x;
        _target.rootLayer.y = parentMousePoint.y;

        //Then maybe snap, if a snap anchor is close enough.
        var closestAnchor :SnapAnchor = getClosestAnchorToTarget();
        if (closestAnchor == null || !closestAnchor.isSnappable(_target)) {
            _currentSnapAnchor = null;
            return;
        }

        var snapPoint :Point = closestAnchor.getSnapToPoint(_target);
        snapToPoint(_target, snapPoint, closestAnchor);
        _currentSnapAnchor = closestAnchor;

    }

    /**
     * Fire an event when the object is snapped to the anchor.
     */
    protected function snapToPoint (snapper :SnappingObject, p :Point, anchor :SnapAnchor) :void
    {
        var d :DisplayObject = snapper.rootLayer;
        if (d.x != p.x && d.y != p.y) {
            dispatchEvent(new ValueEvent(EVENT_OBJECT_SNAPPED, [d, anchor]));
        }

        snapper.snapCenterOfBoundsToPoint(p);
    }

    protected function getClosestAnchorToTarget () :SnapAnchor
    {
        if (_target == null) {
            return null;
        }
        var closestAnchor :SnapAnchor = null;
        var closestDistance :Number = Number.MAX_VALUE;
        var distance :Number;
        var allowedAnchors :Array = _snapAnchors;
        if (_allowedAnchorsFunction != null) {
            var allowedAnchorDisplayObjects :Array = _allowedAnchorsFunction(_target.boundsDisplay);
            allowedAnchors = allowedAnchors.filter(
                function (anchor :SnapAnchor, ...ignored) :Boolean {
                    return ArrayUtil.contains(allowedAnchorDisplayObjects, anchor.displayObject);
                });
        }

        for each (var anchor :SnapAnchor in _snapAnchors) {
            distance = anchor.getSnappableDistance(_target);
            if (distance < closestDistance) {
                closestDistance = distance;
                closestAnchor = anchor;
            }
        }
        return closestAnchor;
    }

    protected var _parent :Sprite;
    protected var _target :SnappingObject;
    protected var _snappableObjects :Map = Maps.newMapOf(DisplayObject);
    protected var _snapAnchors :Array = [];
    protected var _currentSnapAnchor :SnapAnchor;
    protected var _allowedAnchorsFunction :Function;
    protected var _events :EventHandlerManager = new EventHandlerManager();
    protected var _mouseDownEvents :EventHandlerManager = new EventHandlerManager();

}
}