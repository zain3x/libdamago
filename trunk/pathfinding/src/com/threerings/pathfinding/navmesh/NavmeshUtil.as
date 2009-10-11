package com.threerings.pathfinding.navmesh {
import flash.display.Graphics;
public class NavmeshUtil
{
    /**
     * We assume that the board will not have more than 10000 units.  So a somewhat unique
     * id for a pair of units can be created by multipling the larger number by 100000 and
     * adding it to the smaller number.
     */
    public static function hashForIdPair (id1 :int, id2 :int, maxid :int = 10000) :int
    {
        return Math.max(id1, id2) * maxid + Math.min(id1, id2);
    }


    public static function drawGrid (graphics :Graphics, size :int, color :int = 0x000000) :void
    {
        var bars :int = 10;
        graphics.lineStyle(1, color, 0.3);
        for( var i :int = 0; i < bars; i++) {
            graphics.moveTo( i * size, 0);
            graphics.lineTo( i * size, size * bars);

            graphics.moveTo(0, i * size);
            graphics.lineTo(size * bars, i * size);
        }
    }
}
}
