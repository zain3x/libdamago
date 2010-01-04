package com.threerings.util
{
import com.threerings.geom.Vector2;

import flash.geom.Rectangle;

public class GeomUtil
{
    public static function createDistribution (left :Number, top :Number, widthCount :int,
        heightCount :int, interval :Number) :Array //<Vector2>
    {
        var vs :Array = [];

        for (var ii :int = 0; ii < widthCount; ++ii) {
            for (var jj :int = 0; jj < heightCount; ++jj) {
                vs.push(new Vector2(left + ii * interval, top + jj * interval));
            }
        }

        return vs;
    }
	
	public static function rectCenter (rect :Rectangle) :Vector2
	{
		return new Vector2(rect.left + rect.width / 2, rect.top + rect.height / 2);
	}
}
}
