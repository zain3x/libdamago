package com.threerings.ui.snapping {
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

import libdamago.util.SortingUtil;

public class SnapUtil
{
    public static function snapCenterOfBoundsToGlobalPoint (sn :ISnappingObject,
        globalPoint :Point) :void
    {
        var localPoint :Point = sn.displayObject.parent.globalToLocal(globalPoint);
        var bounds :Rectangle = sn.localBounds.boundingRect();
        var boundsCenterX :Number = bounds.left + bounds.width / 2;
        var boundsCenterY :Number = bounds.top + bounds.height / 2;
        sn.displayObject.x = localPoint.x - boundsCenterX;
        sn.displayObject.y = localPoint.y - boundsCenterY;
//        sn.displayObject.x = localPoint.x;
//        sn.displayObject.y = localPoint.y + 10;
    }

//    public static function getSnappableDistanceFromSnapPointAnchor (anchor :ISnapAnchor,
//        d :ISnappingObject, offset :Point = null) :Number
//    {
//        offset = offset == null ? new Point : offset;
//        var globalSnapping :Point = d.displayObject.localToGlobal(new Point(0, 0));
//        var globalAnchor :Point = new Point(
//            anchor.globalBounds.left + anchor.globalBounds.width / 2, anchor.globalBounds.top + anchor.globalBounds.height / 2);
////        .localToGlobal(offset);
//
//        var parent :DisplayObject = d.displayObject.stage;//anchor.globalBounds.parent;
//        var bounds :Rectangle = d.boundsDisplayObject.getBounds(parent);
//        var centerX :Number = bounds.left + bounds.width / 2;
//        var centerY :Number = bounds.top + bounds.height / 2;
//
//        var distance :Number = MathUtil.distance(globalSnapping.x, globalSnapping.y,
//            globalAnchor.x, globalAnchor.y);
//
//        return distance;
//    }

//    public static function getSnappableDistanceFromSnapRect (anchor :ISnapAnchor,
//        d :ISnappingObject, snapAxis :SnapAxis, maxSnapDistance :Number = 20) :Number
//    {
//        var anchorGlobalBounds :Rectangle =
//            anchor.globalBounds;//.getBounds(anchor.globalBounds.stage);
//        var tRect :Rectangle = d.boundsDisplayObject.getBounds(d.boundsDisplayObject.stage);
//        var leftDistance :Number = Math.abs(anchorGlobalBounds.left - tRect.right);
//        var rightDistance :Number = Math.abs(anchorGlobalBounds.right - tRect.left);
//        var topDistance :Number = Math.abs(anchorGlobalBounds.top - tRect.bottom);
//        var bottomDistance :Number = Math.abs(anchorGlobalBounds.bottom - tRect.top);
//
//        var buffer :Number = maxSnapDistance * 2;
//        var xAxisWithinBounds :Boolean = tRect.left > anchorGlobalBounds.left - buffer &&
//            tRect.right < anchorGlobalBounds.right + buffer;
//        var yAxisWithinBounds :Boolean = tRect.top > anchorGlobalBounds.top - buffer &&
//            tRect.bottom < anchorGlobalBounds.bottom + buffer;
//
//        //If we are too far away, return the max distance
//        //otherwise return the appropriate closest distance.
//        if (!xAxisWithinBounds || !yAxisWithinBounds) {
//            var maxDistance :Number = Math.max(leftDistance, rightDistance, topDistance,
//                bottomDistance);
//            return maxDistance;
//        }
//
//        if (snapAxis == SnapAxis.X) {
//            return Math.min(leftDistance, rightDistance);
//        } else if (snapAxis == SnapAxis.Y) {
//            return Math.min(topDistance, bottomDistance);
//        }
//
//        return Math.min(leftDistance, rightDistance, topDistance, bottomDistance);
//    }

//    public static function getGlobalSnapToPointFromRectOuter (anchor :ISnapAnchor,
//        d :ISnappingObject, snapAxis :SnapAxis, maxSnapDistance :Number = 20) :Point
//    {
//        var stage :DisplayObject = d.displayObject.stage;
////        var anchorGlobalBounds :Rectangle = anchor.globalBounds.getBounds(stage);
//
//        var anchorGlobalBounds :Rectangle = anchor.globalBounds;
//        var tRect :Rectangle = d.boundsDisplayObject.getBounds(d.boundsDisplayObject.stage);
//
////        var tRect :Rectangle = d.boundsDisplayObject.getBounds(stage);
//        var leftDistance :Number = Math.abs(anchorGlobalBounds.left - tRect.right);
//        var rightDistance :Number = Math.abs(anchorGlobalBounds.right - tRect.left);
//        var topDistance :Number = Math.abs(anchorGlobalBounds.top - tRect.bottom);
//        var bottomDistance :Number = Math.abs(anchorGlobalBounds.bottom - tRect.top);
//
//        var p :Point = DisplayUtil.transformPoint(new Point(d.boundsDisplayObject.x,
//            d.boundsDisplayObject.y), d.boundsDisplayObject, stage);
//
//        var buffer :Number = maxSnapDistance * 2;
//        var xAxisWithinBounds :Boolean = tRect.left > anchorGlobalBounds.left - buffer &&
//            tRect.right < anchorGlobalBounds.right + buffer;
//        var yAxisWithinBounds :Boolean = tRect.top > anchorGlobalBounds.top - buffer &&
//            tRect.bottom < anchorGlobalBounds.bottom + buffer;
//
//        if (snapAxis == SnapAxis.X) {
//            if (leftDistance <= maxSnapDistance) {
//                p.x = anchorGlobalBounds.left - tRect.width / 2;
//            } else if (rightDistance <= maxSnapDistance){
//                p.x = anchorGlobalBounds.right + tRect.width / 2;
//            }
//        } else if (snapAxis == SnapAxis.Y) {
//            if (topDistance <= maxSnapDistance) {
//                p.y = anchorGlobalBounds.top - tRect.height / 2;
//            } else if (bottomDistance <= maxSnapDistance){
//                p.y = anchorGlobalBounds.bottom + tRect.height / 2;
//            }
//
//        } else if (snapAxis == SnapAxis.X_AND_Y){
//            if (leftDistance <= maxSnapDistance && yAxisWithinBounds) {
//                p.x = anchorGlobalBounds.left - tRect.width / 2;
//            } else if (rightDistance <= maxSnapDistance && yAxisWithinBounds){
//                p.x = anchorGlobalBounds.right + tRect.width / 2;
//            }
//
//            if (topDistance <= maxSnapDistance && xAxisWithinBounds) {
//                p.y = anchorGlobalBounds.top - tRect.height / 2;
//            } else if (bottomDistance <= maxSnapDistance && xAxisWithinBounds){
//                p.y = anchorGlobalBounds.bottom + tRect.height / 2;
//            }
//        }
//
//        return p;
//    }

//    public static function getGlobalSnapToPointFromPolygonBounds (anchor :ISnapAnchor,
//        d :ISnappingObject, snapAxis :SnapAxis, maxSnapDistance :Number = 20) :Point
//    {
//
//        var stage :DisplayObject = d.displayObject.stage;
//        var anchorGlobalBounds :Rectangle = anchor.globalBounds;
//        var tRect :Rectangle = d.boundsDisplayObject.getBounds(d.boundsDisplayObject.stage);
//
//
////        var stage :DisplayObject = anchor.globalBounds.stage;
////        var anchorGlobalBounds :Rectangle = anchor.globalBounds.getBounds(stage);
////
////        var tRect :Rectangle = d.boundsDisplayObject.getBounds(stage);
//
//        var leftDistance :Number = Math.abs(anchorGlobalBounds.left - tRect.right);
//        var rightDistance :Number = Math.abs(anchorGlobalBounds.right - tRect.left);
//        var topDistance :Number = Math.abs(anchorGlobalBounds.top - tRect.bottom);
//        var bottomDistance :Number = Math.abs(anchorGlobalBounds.bottom - tRect.top);
//
//        var p :Point = DisplayUtil.transformPoint(new Point(d.boundsDisplayObject.x,
//            d.boundsDisplayObject.y), d.boundsDisplayObject, stage);
//
//        var buffer :Number = maxSnapDistance * 2;
//        var xAxisWithinBounds :Boolean = tRect.left > anchorGlobalBounds.left - buffer &&
//            tRect.right < anchorGlobalBounds.right + buffer;
//        var yAxisWithinBounds :Boolean = tRect.top > anchorGlobalBounds.top - buffer &&
//            tRect.bottom < anchorGlobalBounds.bottom + buffer;
//
//        if (snapAxis == SnapAxis.X) {
//            if (leftDistance <= maxSnapDistance) {
//                p.x = anchorGlobalBounds.left - tRect.width / 2;
//            } else if (rightDistance <= maxSnapDistance){
//                p.x = anchorGlobalBounds.right + tRect.width / 2;
//            }
//        } else if (snapAxis == SnapAxis.Y) {
//            if (topDistance <= maxSnapDistance) {
//                p.y = anchorGlobalBounds.top - tRect.height / 2;
//            } else if (bottomDistance <= maxSnapDistance){
//                p.y = anchorGlobalBounds.bottom + tRect.height / 2;
//            }
//
//        } else if (snapAxis == SnapAxis.X_AND_Y){
//            if (leftDistance <= maxSnapDistance && yAxisWithinBounds) {
//                p.x = anchorGlobalBounds.left - tRect.width / 2;
//            } else if (rightDistance <= maxSnapDistance && yAxisWithinBounds){
//                p.x = anchorGlobalBounds.right + tRect.width / 2;
//            }
//
//            if (topDistance <= maxSnapDistance && xAxisWithinBounds) {
//                p.y = anchorGlobalBounds.top - tRect.height / 2;
//            } else if (bottomDistance <= maxSnapDistance && xAxisWithinBounds){
//                p.y = anchorGlobalBounds.bottom + tRect.height / 2;
//            }
//        }
//
//        return p;
//    }

    public static function getGlobalCenter (d :DisplayObject) :Point
    {
        var bounds :Rectangle = d.getBounds(d.stage);
        var centerX :Number = bounds.left + bounds.width / 2;
        var centerY :Number = bounds.top + bounds.height / 2;
        return new Point(centerX, centerY);
    }

    public static function getClosestAnchorIndex (anchors :Array, obj :SnappingObject) :int
    {
        var copy :Array = anchors.slice();
        SortingUtil.sortOnNumberFromFunction(copy, function (anc :ISnapAnchor) :Number {
            return anc.getSnappableDistance(obj);
        });
        return ArrayUtil.indexOf(anchors, copy[0]);
    }
}
}