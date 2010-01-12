package com.threerings.ui.snapping {
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.Bounds;
import com.threerings.util.ArrayUtil;
import com.threerings.util.SortingUtil;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;

public class SnapUtil
{
    public static function snapCenterOfBoundsToGlobalPoint (sn :ISnappingObject,
        globalPoint :Point) :void
    {
        var globalBounds :Bounds = sn.globalBounds;
        var center :Vector2 = globalBounds.center;
//        sn.displayObject.x += globalPoint.x - center.x;
//        sn.displayObject.y += globalPoint.y - center.y;
		
		sn.x += globalPoint.x - center.x;
		sn.y += globalPoint.y - center.y;
		
		
//		
//		sn.x = globalPoint.x// - globalBounds.width / 2;
//		sn.y = globalPoint.y// - globalBounds.height / 2;
//		sn.displayObject.y += globalPoint.y - center.y;

//		trace("snap to: " + globalPoint); 
//        var localPoint :Point = sn.displayObject.parent.globalToLocal(globalPoint);
//		sn.x = localPoint.x// - globalBounds.width / 2;
//		sn.y = localPoint.y// - globalBounds.height / 2;
//        var bounds :Rectangle = sn.localBounds.boundingRect();
//        var boundsCenterX :Number = bounds.left + bounds.width / 2;
//        var boundsCenterY :Number = bounds.top + bounds.height / 2;
//        sn.displayObject.x = localPoint.x - boundsCenterX;
//        sn.displayObject.y = localPoint.y - boundsCenterY;



//        sn.displayObject.x = localPoint.x;
//        sn.displayObject.y = localPoint.y + 10;
    }

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
