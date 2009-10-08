//
// $Id: DebugUtil.as 4934 2009-09-04 17:47:44Z tim $

package com.whirled.contrib.debug{

import com.threerings.util.ClassUtil;
import com.threerings.util.Map;
import com.threerings.util.Util;

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Rectangle;

public class DebugUtil
{
    public static function fillDot (s :Sprite, color :int = 0x00ffff, r :Number = 10,
        x :int = 0, y :int = 0) :void
    {
        s.graphics.beginFill(color);
        s.graphics.drawCircle(x,y,r);
        s.graphics.endFill();
    }

    public static function drawDot (s :Sprite, color :int = 0x00ffff, r :Number = 10,
        x :int = 0, y :int = 0) :void
    {
        s.graphics.lineStyle(1, color);
        s.graphics.drawCircle(x,y,r);
        s.graphics.lineStyle(0, 0, 0);

    }

    public static function drawLine (s :Sprite, x1 :Number, y1 :Number, x2 :Number,
        y2 :Number, color :int = 0x000000, linethickness :Number = 1, alpha :Number = 1) :void
    {
        var g :Graphics = s.graphics;
        g.lineStyle(linethickness, color, alpha);
        g.moveTo(x1, y1);
        g.lineTo(x2, y2);
//        g.lineStyle(0, 0, 0);
    }

    public static function traceDisplayChildren (d :DisplayObjectContainer,
        space :String = " ") :void
    {
        if (d == null) {
            return;
        }
        trace(space + d + ".name=" + d.name);
        for (var ii :int = 0; ii < d.numChildren; ++ii) {
//            if (d.getChildAt(ii) != null && d.getChildAt(ii)["name"] != null) {
//                trace(space + "child" + ii + "=" + d.getChildAt(ii) + ".name=" +
//                    d.getChildAt(ii).name);
//                if (d.getChildAt(ii) is DisplayObjectContainer) {
//                    traceDisplayChildren(DisplayObjectContainer(d.getChildAt(ii)), space + "  ");
//                }
//            }
            if (d.getChildAt(ii) is DisplayObjectContainer) {
                traceDisplayChildren(DisplayObjectContainer(d.getChildAt(ii)), space + "  ");
            }
        }
    }

    public static function traceParentage (d :DisplayObject, space :String = " ") :void
    {
        if (d == null) {
            return;
        }

        var lineage :Array = [d.name];
        var current :DisplayObject = d.parent;
        while (current != null) {
            lineage.unshift(current.name + "(" + ClassUtil.tinyClassName(current) + ")");
            current = current.parent;
        }
        trace("Lineage: " + lineage.join(" "));
    }

    public static function drawBoundingRect (layer :Sprite, rootContainer :DisplayObjectContainer,
        color :int = 0xffffff, alpha :Number = 0) :void
    {
        var bounds :Rectangle = rootContainer.getBounds(rootContainer);
        var g :Graphics = layer.graphics;
        g.clear();
        g.beginFill(color, alpha);
        g.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
        g.endFill();
    }

    public static function drawRect (layer :Sprite, width :int, height :int, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.lineStyle(1, color, alpha);
        g.drawRect(0, 0, width, height);
    }

    public static function fillRect (layer :Sprite, width :int, height :int, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.lineStyle(0,0,0);
        g.beginFill(color, alpha);
        g.drawRect(0, 0, width, height);
        g.endFill();
    }

    public static function applyAllChildren (d :DisplayObjectContainer, f :Function) :void
    {
        f(d);
        for (var ii :int = 0; ii < d.numChildren; ++ii) {
            var child :DisplayObject = d.getChildAt(ii);
            f(child);
            if (child is DisplayObjectContainer) {
                applyAllChildren(DisplayObjectContainer(child), f);
            }
        }
    }

    public static function mapToProp (arr :Array, propName :String) :Array
    {
        return arr.map(Util.adapt(function (obj :Object) :Object {
            return obj[propName];
        }));
    }

    public static function mapToString (h :Map) :String
    {
        var sb :String = "";
        for each (var key :String in h.keys()) {
            sb += "\n" + key + "=" + h.get(key);
        }
        return sb;
    }
}
}
