//
// $Id$

package com.threerings.ui.snapping
{
import flash.display.DisplayObject;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.display.DisplayUtil;

public class SnapAnchorRect extends SnapAnchor
{
    public function SnapAnchorRect (snappingObj :DisplayObject, parent :Sprite,
        snapAxis :SnapAxis, maxSnapDistance :Number = 20)
    {
        super(SnapType.BORDER, snappingObj, maxSnapDistance);
        _parent = parent;
        _rect = snappingObj.getRect(_parent);
        _snapAxis = snapAxis;
    }

    override internal function getSnappableDistance (d :SnappingObject) :Number
    {
        var tRect :Rectangle = d.boundsDisplay.getBounds(_parent);
        var leftDistance :Number = Math.abs(_rect.left - tRect.right);
        var rightDistance :Number = Math.abs(_rect.right - tRect.left);
        var topDistance :Number = Math.abs(_rect.top - tRect.bottom);
        var bottomDistance :Number = Math.abs(_rect.bottom - tRect.top);

        var buffer :Number = _maxSnapDistance * 2;
        var xAxisWithinBounds :Boolean = tRect.left > _rect.left - buffer && tRect.right < _rect.right + buffer;
        var yAxisWithinBounds :Boolean = tRect.top > _rect.top - buffer && tRect.bottom < _rect.bottom + buffer;

        //If we are too far away, return the max distance
        //otherwise return the appropriate closest distance.
        if (!xAxisWithinBounds || !yAxisWithinBounds) {
            var maxDistance :Number = Math.max(leftDistance, rightDistance, topDistance, bottomDistance);
            return maxDistance;
        }

        if (_snapAxis == SnapAxis.X) {
            return Math.min(leftDistance, rightDistance);
        } else if (_snapAxis == SnapAxis.Y) {
            return Math.min(topDistance, bottomDistance);
        }

        return Math.min(leftDistance, rightDistance, topDistance, bottomDistance);
    }

    /**
     * The point to snap to is the center of the boundsDisplay.
     */
    override internal function getSnapToPoint (d :SnappingObject) :Point
    {
        var tRect :Rectangle = d.boundsDisplay.getBounds(_parent);
        var leftDistance :Number = Math.abs(_rect.left - tRect.right);
        var rightDistance :Number = Math.abs(_rect.right - tRect.left);
        var topDistance :Number = Math.abs(_rect.top - tRect.bottom);
        var bottomDistance :Number = Math.abs(_rect.bottom - tRect.top);

        var p :Point = DisplayUtil.transformPoint(new Point(d.boundsDisplay.x,d.boundsDisplay.y), d.boundsDisplay, _parent);

        var buffer :Number = _maxSnapDistance * 2;
        var xAxisWithinBounds :Boolean = tRect.left > _rect.left - buffer && tRect.right < _rect.right + buffer;
        var yAxisWithinBounds :Boolean = tRect.top > _rect.top - buffer && tRect.bottom < _rect.bottom + buffer;

        if (_snapAxis == SnapAxis.X) {
            if (leftDistance <= _maxSnapDistance) {
                p.x = _rect.left - tRect.width / 2;
            } else if (rightDistance <= _maxSnapDistance){
                p.x = _rect.right + tRect.width / 2;
            }
        } else if (_snapAxis == SnapAxis.Y) {
            if (topDistance <= _maxSnapDistance) {
                p.y = _rect.top - tRect.height / 2;
            } else if (bottomDistance <= _maxSnapDistance){
                p.y = _rect.bottom + tRect.height / 2;
            }

        } else if (_snapAxis == SnapAxis.X_AND_Y){
            if (leftDistance <= _maxSnapDistance && yAxisWithinBounds) {
                p.x = _rect.left - tRect.width / 2;
            } else if (rightDistance <= _maxSnapDistance && yAxisWithinBounds){
                p.x = _rect.right + tRect.width / 2;
            }

            if (topDistance <= _maxSnapDistance && xAxisWithinBounds) {
                p.y = _rect.top - tRect.height / 2;
            } else if (bottomDistance <= _maxSnapDistance && xAxisWithinBounds){
                p.y = _rect.bottom + tRect.height / 2;
            }
        }

        return p;
    }

    protected var _parent :Sprite;
    protected var _rect :Rectangle;
    protected var _snapAxis :SnapAxis;
}
}