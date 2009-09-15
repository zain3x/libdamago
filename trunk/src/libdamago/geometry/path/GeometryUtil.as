package libdamago.geometry.path
{
import com.threerings.util.MathUtil;

import libdamago.geometry.Geometry;

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
}
}
