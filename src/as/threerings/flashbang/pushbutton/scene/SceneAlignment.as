//
// $Id$

package com.threerings.flashbang.pushbutton.scene {
import com.threerings.util.Enum;

import flash.geom.Point;
/**
 * SceneAlignment enum.
 */
public final class SceneAlignment extends Enum
{
    // DEFINE MEMBERS HERE
    public static const BOTTOM_LEFT :SceneAlignment = new SceneAlignment("BOTTOM_LEFT");
    public static const BOTTOM_RIGHT :SceneAlignment = new SceneAlignment("BOTTOM_RIGHT");
    public static const CENTER :SceneAlignment = new SceneAlignment("CENTER");
    public static const TOP_LEFT :SceneAlignment = new SceneAlignment("TOP_LEFT");
    public static const TOP_RIGHT :SceneAlignment = new SceneAlignment("TOP_RIGHT");
    finishedEnumerating(SceneAlignment);

    public static const DEFAULT_ALIGNMENT :SceneAlignment = CENTER;

    /**
     * Given an alignment constant from this class, calculate
     * @param outPoint
     * @param alignment
     * @param sceneWidth
     * @param sceneHeight
     *
     */
    public static function calculate (outPoint :Point, alignment :SceneAlignment, sceneWidth :Number,
        sceneHeight :Number) :void
    {
        switch (alignment) {
            case CENTER:
                outPoint.x = sceneWidth * 0.5;
                outPoint.y = sceneHeight * 0.5;
                break;
            case TOP_LEFT:
                outPoint.x = outPoint.y = 0;
                break;
            case TOP_RIGHT:
                outPoint.x = sceneWidth;
                outPoint.y = 0;
                break;
            case BOTTOM_LEFT:
                outPoint.x = 0;
                outPoint.y = sceneHeight;
                break;
            case BOTTOM_RIGHT:
                outPoint.x = sceneWidth;
                outPoint.y = sceneHeight;
                break;
        }
    }

    /**
     * Get the value of the SceneAlignment enum that corresponds to the specified string.
     * If the value requested does not exist, an ArgumentError will be thrown.
     */
    public static function valueOf (name :String) :SceneAlignment
    {
        return Enum.valueOf(SceneAlignment, name) as SceneAlignment;
    }

    /**
     * Get the values of the SceneAlignment enum
     */
    public static function values () :Array
    {
        return Enum.values(SceneAlignment);
    }

    /** @private */
    public function SceneAlignment (name :String)
    {
        super(name);
    }
}
}
