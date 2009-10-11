//
// $Id$

package com.threerings.ui.snapping
{
import com.threerings.ui.bounds.BoundsRectangle;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;

import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.EventDispatcher;
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

    public static const DEBUG_DRAW :Boolean = true;

    public function SnapManager (parent :Sprite)
    {
        _parent = parent;
        _debugLayer.mouseEnabled = false;
        _debugLayer.mouseChildren = false;
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
        _parent.addEventListener(Event.ENTER_FRAME, handleEnterFrame);
    }

    public function clear () :void
    {
        endSnapping();
        _snapAnchors = [];
        _target = null;
    }

    public function endSnapping (snapper :ISnappingObject = null) :void
    {
//        _events.freeAllHandlers();
        _parent.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
        _target = null;
        _debugLayer.graphics.clear();
    }

    public function shutdown () :void
    {
        clear();
        _parent = null;
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

    protected function handleEnterFrame (...ignored) :void
    {
        if (_target == null) {
            return;
        }

        var stage :DisplayObject = _parent.stage;
        //First move it to the mouse coords
        SnapUtil.snapCenterOfBoundsToGlobalPoint(_target, new Point(stage.mouseX, stage.mouseY));

        var snapped :Boolean = false;
        var anc :ISnapAnchor;
        //Sort snap anchors by distance to target, so that the closest anchor snaps last
        ArrayUtil.stableSort(_snapAnchors, function (anc1 :ISnapAnchor, anc2 :ISnapAnchor) :int {
           return anc1.getSnappableDistance(_target) < anc2.getSnappableDistance(_target) ? 1 : -1;
        });

//        if (_snapAnchors.length > 0) {
//            anc = ISnapAnchor(_snapAnchors[0]);
//            if (anc.isWithinSnappingDistance(_target)) {
//                anc.snapObject(_target);
//                //Dispatch event whether we snap or not to indicate snapping/no snapping
//                dispatchEvent(new SnapEvent(anc, _target));
//                snapped = true;
//            }
//        }

        //Snap to all anchors close enough
        for each (anc in _snapAnchors) {
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

        if (DEBUG_DRAW) {
            _debugLayer.graphics.clear();
            _parent.addChildAt(_debugLayer, _parent.numChildren);
            var translate :Point = _debugLayer.globalToLocal(new Point(0,0));
            for each (anc in _snapAnchors) {
                if (anc == null) {
                    continue;
                }
                anc.bounds.translate(translate.x, translate.y).debugDraw(_debugLayer);
                BoundsRectangle.fromRectangle(anc.bounds.translate(translate.x,
                    translate.y).boundingRect()).debugDraw(_debugLayer);

            }
            BoundsRectangle.fromRectangle(_target.globalBounds.translate(translate.x,
                translate.y).boundingRect()).debugDraw(_debugLayer);
            _target.globalBounds.translate(translate.x, translate.y).debugDraw(_debugLayer);
        }
    }
    protected var _debugLayer :Sprite = new Sprite();

    protected var _parent :Sprite;
    protected var _snapAnchors :Array = [];
    protected var _target :ISnappingObject;
}
}
