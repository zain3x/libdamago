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

    /**
     * Snap all anchors, or just the closest;
     */
    public var snapAllAnchors :Boolean = false;

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
        _parent.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
        handleEnterFrame();
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
    }

    public function endSnapping (snapper :ISnappingObject = null) :void
    {
        _parent.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _target = null;
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
            if (distance < closestDistance) {
                closestDistance = distance;
                closestAnchor = anchor;
            }
        }
        return closestAnchor;
    }

    protected function handleEnterFrame (... ignored) :void
    {
        //Reset the re-usable snapEvent
        _snapEvent.anchor = null;
        _snapEvent.snapped = _target;
        
        if (_target == null) {
            return;
        }

        
        var stage :DisplayObject = _parent.stage;
        //First move it to the mouse coords
        var mouseLoc :Point = new Point(stage.mouseX, stage.mouseY);
        _target.snapCenterToGlobal(mouseLoc);

        var snapped :Boolean = false;
        var anc :ISnapAnchor;
        //Sort snap anchors by distance to target, so that the closest anchor snaps last
        ArrayUtil.stableSort(_snapAnchors, function (anc1 :ISnapAnchor, anc2 :ISnapAnchor) :int {
                return anc1.getSnappableDistance(_target) < anc2.getSnappableDistance(_target) ?
                    -1 : 1;
            });

        if (snapAllAnchors) {
            //Snap to all anchors close enough
            for each (anc in _snapAnchors) {

                if (anc.isWithinSnappingDistance(_target)) {
                    anc.snapObject(_target);
                    //Dispatch event whether we snap or not to indicate snapping/no snapping
                    _snapEvent.anchor = anc;
                    dispatchEvent(_snapEvent);
                    snapped = true;
                }
            }
        } else {
            if (_snapAnchors.length > 0) {
                anc = ISnapAnchor(_snapAnchors[0]);
                if (anc.isWithinSnappingDistance(_target)) {
                    anc.snapObject(_target);
                    //Dispatch event whether we snap or not to indicate snapping/no snapping
                    _snapEvent.anchor = anc;
                    dispatchEvent(_snapEvent);
                    snapped = true;
                }
            }
        }

        //If nothing is snapped, inform listeners of this
        if (!snapped) {
            _snapEvent.anchor = null;
            dispatchEvent(_snapEvent);
        }

        if (DEBUG_DRAW) {
            _debugLayer.graphics.clear();
            _parent.addChildAt(_debugLayer, _parent.numChildren);
            for each (anc in _snapAnchors) {
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
    protected var _snapEvent :SnapEvent = new SnapEvent(null, null);
}
}
