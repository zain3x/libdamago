package com.threerings.geometry.path
{
import com.threerings.geom.Vector2;
import com.threerings.util.MathUtil;

import flash.geom.Rectangle;

import com.threerings.geometry.Geometry;

public class GeometryUtil
{
    /**
     * Normalizes an angle in radians to occupy the [-pi, pi) range.
     */
    public static function angleDirection (radians :Number) :Number
    {
        radians = MathUtil.normalizeRadians(radians);
        if (radians > Math.PI) {
            radians = Geometry.PI_2 - radians;
        }
        return radians;
    }

    public static function rectCenter (rect :Rectangle) :Vector2
    {
        return new Vector2(rect.left + rect.width / 2, rect.top + rect.height / 2);
    }
}
}
