//
// $Id$

package com.threerings.util {
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Graphics;
import flash.display.SimpleButton;
import flash.display.Sprite;
import flash.events.MouseEvent;
import flash.geom.Rectangle;
import flash.utils.Dictionary;

import com.threerings.ui.SimpleTextButton;

import com.threerings.util.F;

public class DebugUtil
{

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

    public static function createButton (text :String, callback :Function,
        parent :DisplayObjectContainer, x :int = 0, y :int = 0) :SimpleTextButton
    {
        var b :SimpleTextButton = new SimpleTextButton(text);
        b.x = x;
        b.y = y;
        b.addEventListener(MouseEvent.CLICK, F.callback(callback));
        parent.addChild(b);
        return b;
    }

    public static function createDebugLayer (debugcall :Function, args :Array) :Sprite
    {
        trace("createDebugLayer args=" + args.join(", "));
        var layer :Sprite = new Sprite();
        args.unshift(layer);
        trace("after adding sprite args=" + args.join(", "));
        debugcall.apply(null, args);
        return layer;
    }

    public static function dictToString (h :Dictionary) :String
    {
        var sb :String = "";

        if (h == null) {
            return sb;
        }
        for each (var key :Object in h) {
            sb += "\n" + key + "=" + h[key];
        }
        return sb;
    }

    public static function drawBoundingRect (disp :DisplayObject, drawLayer :Sprite, color :uint =
        0x000000, alpha :Number = 1) :void
    {
        var bounds :Rectangle = disp.getBounds(drawLayer);
        var g :Graphics = drawLayer.graphics;
        g.lineStyle(1, color, alpha);
        g.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
    }

    public static function drawDot (s :Sprite, color :int = 0x00ffff, r :Number = 10, x :int = 0,
        y :int = 0) :void
    {
        s.graphics.lineStyle(1, color);
        s.graphics.drawCircle(x, y, r);
        s.graphics.lineStyle(0, 0, 0);

    }

    public static function drawLine (s :Sprite, x1 :Number, y1 :Number, x2 :Number, y2 :Number,
        color :int = 0x000000, linethickness :Number = 1, alpha :Number = 1) :void
    {
        var g :Graphics = s.graphics;
        g.lineStyle(linethickness, color, alpha);
        g.moveTo(x1, y1);
        g.lineTo(x2, y2);
        //        g.lineStyle(0, 0, 0);
    }

    public static function drawRect (layer :Sprite, width :int, height :int, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.lineStyle(1, color, alpha);
        g.drawRect(0, 0, width, height);
    }

    public static function drawRectangle (layer :Sprite, rect :Rectangle, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.lineStyle(1, color, alpha);
        g.drawRect(rect.left, rect.top, rect.width, rect.height);
    }

    public static function fillBoundingRect (layer :Sprite, rootContainer :DisplayObjectContainer,
        color :int = 0xffffff, alpha :Number = 0) :void
    {
        var bounds :Rectangle = rootContainer.getBounds(rootContainer);
        var g :Graphics = layer.graphics;
        g.clear();
        g.beginFill(color, alpha);
        g.drawRect(bounds.left, bounds.top, bounds.width, bounds.height);
        g.endFill();
    }

    public static function fillDot (s :Sprite, color :int = 0x00ffff, r :Number = 10, x :int = 0,
        y :int = 0) :void
    {
        s.graphics.beginFill(color);
        s.graphics.drawCircle(x, y, r);
        s.graphics.endFill();
    }

    public static function fillRect (layer :Sprite, width :int, height :int, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.lineStyle(0, 0, 0);
        g.beginFill(color, alpha);
        g.drawRect(0, 0, width, height);
        g.endFill();
    }

    public static function fillRectangle (layer :Sprite, rect :Rectangle, color :int = 0x000000,
        alpha :Number = 1) :void
    {
        var g :Graphics = layer.graphics;
        g.beginFill(color, alpha);
        g.drawRect(rect.left, rect.top, rect.width, rect.height);
        g.endFill();
    }

    public static function getStackTrace () :String
    {
        try {
            throw new Error();
        } catch (e :Error) {
            return e.getStackTrace();
        }
        return "";
    }

    public static function mapToProp (arr :Array, propName :String) :Array
    {
        return arr.map(Util.adapt(function (obj :Object) :Object {
                return obj[propName];
            }));
    }

    public static function mapToString (h :Map, keyFunc :Function = null, valFunc :Function =
        null) :String
    {
        var sb :String = "";

        if (h == null) {
            return sb;
        }
        for each (var key :* in h.keys()) {
            var ks :String = keyFunc == null ? String(key) : keyFunc(key);
            var vs :String = valFunc == null ? String(h.get(key)) : valFunc(h.get(key));
            sb += "\n" + ks + "=" + vs;
        }
        return sb.substring(1);
    }

    public static function traceCallback (s :String) :Function
    {
        return F.callback(function () :void {
                trace(s);
            });
    }

    public static function traceDisplayChildren (d :DisplayObject, space :String = " ") :void
    {
        if (d == null) {
            return;
        }
        trace(space + extendedDisplayObjectName(d));

        if (d is SimpleButton) {
            traceDisplayChildren(SimpleButton(d).upState, space + "  ");
            traceDisplayChildren(SimpleButton(d).downState, space + "  ");
            traceDisplayChildren(SimpleButton(d).overState, space + "  ");
            traceDisplayChildren(SimpleButton(d).hitTestState, space + "  ");
        } else {
            if (d is DisplayObjectContainer) {
                var parent :DisplayObjectContainer = DisplayObjectContainer(d);

                for (var ii :int = 0; ii < parent.numChildren; ++ii) {
                    if (parent.getChildAt(ii) is DisplayObjectContainer) {
                        traceDisplayChildren(DisplayObjectContainer(parent.getChildAt(ii)),
                            space + "  ");
                    }
                }

            }
        }
    }

    public static function traceParentage (d :DisplayObject, space :String = " ") :void
    {
        if (d == null) {
            return;
        }

        var lineage :Array = [ extendedDisplayObjectName(d)];
        var current :DisplayObject = d.parent;
        while (current != null) {
            lineage.unshift(extendedDisplayObjectName(current));
            current = current.parent;
        }

        for (var ii :int = 0; ii < lineage.length; ++ii) {
            lineage[ii] = space + lineage[ii];
            space = space + "  ";
        }

        trace("Lineage:\n" + lineage.join("\n"));
    }

    protected static function extendedDisplayObjectName (d :DisplayObject) :String
    {
        return d + ".name=" + d.name + "  loc=" + d.x + " " + d.y;
    }
    //    public static function byteClone (obj :Streamable) :Streamable
    //    {
    //        var bytes :ByteArray = new ByteArray();
    //        var output :ObjectOutputStream = new ObjectOutputStream(bytes);
    //        var input :ObjectInputStream = new ObjectInputStream(bytes);
    //
    //        var clazz :Class = ClassUtil.getClass(obj);
    //        obj.writeObject(output);
    //        bytes.position = 0;
    //
    //        var streamed :Streamable = new clazz();
    //
    //        streamed.readObject(input);
    //        return streamed;
    //    }
}
}
