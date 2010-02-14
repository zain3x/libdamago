package com.threerings.util
{
import flash.display.Graphics;

public class GraphicsUtils
{
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
