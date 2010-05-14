//
// $Id$

package com.threerings.ui.snapping {
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.BoundsRectangle;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.DisplayUtils;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.geom.Point;

import net.amago.util.EventDispatcherNonCloning;

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
public class SnapManager extends EventDispatcherNonCloning //Recycle snap events
{

    public static var DEBUG_DRAW :Boolean = false;

    public function SnapManager (parent :Sprite, debugDraw :Boolean = false)
    {
        _parent = parent;
        DEBUG_DRAW = debugDraw;
        _debugLayer.mouseEnabled = false;
    }

    public function get snapAnchors () :Array
    {
        //Return a copy
        return _snapAnchors.concat();
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
        snapper.beginSnapping(this);
        attachSnapAnchors();
        _target = snapper;
        _snapEvent.snapped = _target;
        _parent.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        handleEnterFrame();
    }

    protected function attachSnapAnchors () :void
    {
        for each (var anc :ISnapAnchor in _snapAnchors) {
            if (anc.displayObject != null) {
                _parent.addChild(anc.displayObject);
                var center :Vector2 = anc.bounds.center;
                anc.displayObject.x = center.x;
                anc.displayObject.y = center.y;
            }
        }
    }

    protected function detachSnapAnchors () :void
    {
        for each (var anc :ISnapAnchor in _snapAnchors) {
            DisplayUtils.detach(anc.displayObject);
        }
    }

    public function clear () :void
    {
        endSnapping();
        _snapAnchors = [];
        _target = null;
        _lastFrame = null;
    }

    public function endSnapping (snapper :ISnappingObject = null) :void
    {
        _parent.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _target = null;
        _lastFrame = null;
        _debugLayer.graphics.clear();
        //Reset the re-usable snapEvent
        _snapEvent.anchor = null;
        _snapEvent.snapped = null;
        detachSnapAnchors();
    }

    public function shutdown () :void
    {
        clear();
        _parent = null;
        detachSnapAnchors();
    }

    override public function toString () :String
    {
        return ClassUtil.tinyClassName(this) + " snapAnchors(" + _snapAnchors.length + ")=" +
            _snapAnchors;
    }

    protected function handleEnterFrame (... ignored) :void
    {
        var stage :DisplayObject = _parent.stage;
        var mouseLoc :Point = new Point(stage.mouseX, stage.mouseY);
        if (_target == null || (_lastFrame != null && mouseLoc.equals(_lastFrame))) {
            return;
        }
        _lastFrame = mouseLoc;


        _target.snapCenterToGlobal(mouseLoc);

        //Sort snap anchors by distance to target, so that the closest anchor snaps last
        var closest :ISnapAnchor;
        var closestDistance :Number = Number.MAX_VALUE;

        for each (var anchor :ISnapAnchor in _snapAnchors) {
            var distance :Number = anchor.getSnappableDistance(_target);
            if (distance < closestDistance) {
                closestDistance = distance;
                closest = anchor;
            }
        }

        if (closest != null && closest.isWithinSnappingDistance(_target)) {
            closest.snapObject(_target);
        }
        //If nothing is snapped, still inform listeners of this
        _snapEvent.anchor = closest;
        dispatchEvent(_snapEvent);

        if (DEBUG_DRAW) {
            _debugLayer.graphics.clear();
            _parent.addChildAt(_debugLayer, _parent.numChildren);
            for each (var anc :ISnapAnchor in _snapAnchors) {
                if (anc == null) {
                    continue;
                }
                anc.bounds.debugDraw(_debugLayer);
                BoundsRectangle.fromRectangle(anc.bounds.boundingRect()).debugDraw(_debugLayer);

            }
            _target.globalBounds.debugDraw(_debugLayer);
        }
    }

    protected var _debugLayer :Sprite = new Sprite();

    protected var _parent :Sprite;
    protected var _snapAnchors :Array = [];
    protected var _target :ISnappingObject;
    protected var _lastFrame :Point;
    protected var _snapEvent :SnapEvent = new SnapEvent(null, null);
}
}
