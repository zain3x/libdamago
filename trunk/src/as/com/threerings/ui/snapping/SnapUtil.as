package com.threerings.ui.snapping {
import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import com.threerings.geom.Vector2;
import com.threerings.ui.bounds.Bounds;
import com.threerings.util.ArrayUtil;
import com.threerings.util.DebugUtil;
import com.threerings.util.SortingUtil;

public class SnapUtil
{

    public static function getClosestAnchorIndex (anchors :Array, obj :SnappingObject) :int
    {
        var copy :Array = anchors.slice();
        SortingUtil.sortOnNumberFromFunction(copy, function (anc :ISnapAnchor) :Number {
                return anc.getSnappableDistance(obj);
            });
        return ArrayUtil.indexOf(anchors, copy[0]);
    }

    public static function getGlobalCenter (d :DisplayObject) :Point
    {
        var bounds :Rectangle = d.getBounds(d.stage);
        var centerX :Number = bounds.left + bounds.width / 2;
        var centerY :Number = bounds.top + bounds.height / 2;
        return new Point(centerX, centerY);
    }

    public static function snapCenterOfBoundsToGlobalPoint (sn :ISnappingObject,
        globalPoint :Point) :void
    {

        var globalBounds :Bounds = sn.globalBounds;
        var center :Vector2 = globalBounds.center;

        sn.x += globalPoint.x - center.x;
        sn.y += globalPoint.y - center.y;
    }
}
}
