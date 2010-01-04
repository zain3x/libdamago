//
// $Id$

package com.threerings.util {

import aduros.util.F;

import com.threerings.text.TextFieldUtil;

import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.system.LoaderContext;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;

public class DisplayUtils
{
    public static const LEFT_TO_RIGHT :int = 0;
    public static const RIGHT_TO_LEFT :int = 1;
    public static const TOP_TO_BOTTOM :int = 2;
    public static const BOTTOM_TO_TOP :int = 3;

    public static function detach (d :DisplayObject) :void
    {
        if (d != null && d.parent != null) {
            d.parent.removeChild(d);
        }
    }

    public static function removeAllChildren (parent :DisplayObject) :void
    {
        if (parent == null || !(parent is DisplayObjectContainer)) {
            return;
        }
        while (DisplayObjectContainer(parent).numChildren > 0) {
			DisplayObjectContainer(parent).removeChildAt(0);
        }
    }

    public static function drawText (parent :DisplayObjectContainer, text :String, x :int = 0,
        y :int = 0, center :Boolean = true, initProps :Object = null) :TextField
    {
        if (initProps == null) {
            initProps = {};
        }
        initProps.x = x;
        initProps.y = y;
        initProps.selectable = false;
        initProps.mouseEnabled = false;
        var tf :TextField = TextFieldUtil.createField(text, initProps);
        parent.addChild(tf);
        if (center) {
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.width = tf.textWidth;
            tf.height = tf.textHeight;
            tf.x -= tf.width / 2;
            tf.y -= tf.height / 2;

        } else {
            tf.autoSize = TextFieldAutoSize.LEFT;
            tf.width = tf.textWidth;
            tf.height = tf.textHeight;
        }
        return tf;
    }

    public static function distributeChildrenVertically (disp :DisplayObject, startTop :Number = 0) :void
    {
        if (!(disp is DisplayObjectContainer)) {
            return;
        }

        var container :DisplayObjectContainer = DisplayObjectContainer(disp);
        var bounds :Rectangle;
        var child :DisplayObject;
        for (var ii :int = 0; ii < container.numChildren; ++ii) {
            child = container.getChildAt(ii) as DisplayObject;
            if (child == null) {
                continue;
            }
            bounds = child.getBounds(container);
            child.y += startTop - bounds.top;
            startTop = startTop + bounds.height;
        }

    }

    public static function placeSequence (parent :DisplayObjectContainer, seq :Array, startX :int,
        startY :int, direction :int = 0, gap :int = 5, center :Boolean = true) :void
    {
        if (seq == null || seq.length == 0 || parent == null) {
            return;
        }

        for each (var d :DisplayObject in seq) {
            if (d == null) {
                continue;
            }
            parent.addChild(d);

            var xAdjust :int = 0;
            var yAdjust :int = 0;


            if (center) {
                if (direction == LEFT_TO_RIGHT) {
                    xAdjust = d.width / 2;

                } else if (direction == RIGHT_TO_LEFT) {
                    xAdjust = -d.width / 2;
                }
                 else if (direction == TOP_TO_BOTTOM) {
                    yAdjust = d.height / 2;
                }
                 else if (direction == BOTTOM_TO_TOP) {
                    yAdjust = -d.height / 2;
                }
                centerOn(d, startX + xAdjust, startY + yAdjust);
            }
            else {
                d.x = startX + xAdjust;
                d.y = startY + yAdjust;
            }

            if (direction == LEFT_TO_RIGHT) {
                startX += d.width + gap;

            } else if (direction == RIGHT_TO_LEFT) {
                startX += -(d.width + gap);
            }
             else if (direction == TOP_TO_BOTTOM) {
                startY += d.height + gap;
            }
             else if (direction == BOTTOM_TO_TOP) {
                startY += -(d.height + gap);
            }
        }
    }

    public static function distribute (seq :Array, startX :int,
        startY :int, endX :int, endY :int) :void
    {
        if (seq == null || seq.length == 0) {
            return;
        }

        var xInc :int = (endX - startX) / (seq.length + 1);
        startX += xInc / 2;
        var yInc :int = (endY - startY) / (seq.length + 1);
        startY += yInc / 2;

        for (var ii :int = 0; ii < seq.length; ++ii) {
            centerOn(seq[ii], startX + ii * xInc, startY + ii * yInc);
        }
    }

    public static function distributionPoint (index :int, length :int, startX :int,
        startY :int, endX :int, endY :int) :Point
    {
        var xInc :int = (endX - startX) / (length + 1);
        startX += xInc;
        var yInc :int = (endY - startY) / (length + 1);
        startY += yInc;
        return new Point(startX + index * xInc, startY + index * yInc);
    }

    public static function centerOn (d :DisplayObject, x :int = 0, y :int = 0) :DisplayObject
    {
        var bounds :Rectangle;
        if (d.parent != null) {
            bounds = d.getBounds(d.parent != null ? d.parent : d);
            var boundsCenterX :int = bounds.left + bounds.width / 2;
            var xDiff :int = d.x - boundsCenterX;
            d.x = x + xDiff;

            var boundsCenterY :int = bounds.top + bounds.height / 2;
            var yDiff :int = d.y - boundsCenterY;
            d.y = y + yDiff;
        } else {//If we're not attached to a parent yet, centering will be ok unless
        //the displayObject is scaled
            d.x = x;
            d.y = y;
            bounds = d.getBounds(d);
            d.x -= (bounds.width / 2) + bounds.left;
            d.y -= (bounds.height / 2) + bounds.top;
        }
        return d;
    }

    public static function shrinkAndCenterOn (disp :DisplayObject, maxSize :int = 20) :DisplayObject
    {
        if (maxSize > 0) {
            var max :int = Math.max(disp.width, disp.height);
            if (max > maxSize) {
                disp.scaleX = disp.scaleY = Number(maxSize) / max;
            }
        }
        var s :Sprite = new Sprite()
        s.addChild(disp);
        DisplayUtils.centerOn(disp);
        return s;
    }

    /**
     * Converts any DisplayObject into a Bitmap.  This can increase the graphical
     * performance of complex MovieClips.
     */
    public static function convertToBitmap (d :DisplayObject, forceCopy :Boolean = false) :Bitmap
    {
        if (d == null) {
            return null;
        }
        if (d is Bitmap && !forceCopy) {
            return d as Bitmap;
        }
        var bounds :Rectangle = d.getBounds(d);
        if (bounds.width == 0 && bounds.height == 0) {
            log.error("convertToBitmap", "d", d, "d.name", d.name, "bounds", bounds);
            return null;
        }

        if (int(bounds.width) == 0 || int(bounds.height) == 0) {
            return null;
        }
        var bd :BitmapData = new BitmapData(int(bounds.width), int(bounds.height), true, 0xffffff);

        bd.draw(d, new Matrix(1, 0, 0, 1, -bounds.left, -bounds.top));

        var bm :Bitmap = new Bitmap(bd);
        return bm;
    }

    /**
     * Creates a bitmap from the given DisplayObject, and positions the bitmap so that it is
     * visually in the same position as the argument.
     */
    public static function substituteBitmap (d :DisplayObject) :Bitmap
    {
        if (d == null) {
            return null;
        }
        if (d is Bitmap) {
            return d as Bitmap;
        }
        var bm :Bitmap = convertToBitmap(d);
        if (bm == null) {
            return null;
        }

        var bounds :Rectangle = d.getBounds(d);

        //Center it according to the offsets.
        bm.x = bounds.left;
        bm.y = bounds.top;
        return bm;
    }

    public static function getChildren (d :DisplayObjectContainer) :Array
    {
        var children :Array = [];

        if (d == null) {
            return children;
        }

        for (var ii :int = 0; ii < d.numChildren; ++ii) {
            if (d.getChildAt(ii) != null) {
                children.push(d.getChildAt(ii));
            }
        }
        return children;
    }

    public static function loadBitmapFromUrl (url :String,
        loadedBitmapDataCallback :Function = null) :Bitmap
    {
        if (url == null) {
            return null;
        }

        var bm :Bitmap = new Bitmap();
        try {
            var imageLoader :Loader = new Loader();
            var loaderContext :LoaderContext = new LoaderContext();
            loaderContext.checkPolicyFile = true;


            function onComplete () :void {
                if (imageLoader.content != null && imageLoader.content is DisplayObject) {
                    var bd :BitmapData = createBitmapData(imageLoader.content as DisplayObject);
                    bm.bitmapData = bd;
                    if (loadedBitmapDataCallback != null) {
                        loadedBitmapDataCallback(bd);
                    }
                }
            }

            var request :URLRequest = new URLRequest(url);
            imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,
                F.justOnce(F.callback(onComplete)));
            imageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function (...ignored) :void {
                log.error("URL not found: " + url);
            });
            imageLoader.load(request, loaderContext);

        } catch (err :IOErrorEvent) {
            log.error("URL not found: " + url);
        }

        return bm;
    }

    public static function getCenterOffset (d :DisplayObject) :Point
    {
        return getCenterOffsetRelativeTo(d, d);
    }

    public static function getCenterOffsetRelativeTo (d :DisplayObject,
        relativeTo :DisplayObject) :Point
    {
        var bounds :Rectangle = d.getBounds(relativeTo);
        var centerX :Number = bounds.left + bounds.width / 2;
        var centerY :Number = bounds.top + bounds.height / 2;

        return new Point(centerX - d.x, centerY - d.y);
    }

    public static function getBoundsCenterRelativeTo (d :DisplayObject, relativeTo :DisplayObject) :Point
    {
        var bounds :Rectangle = d.getBounds(relativeTo);
        return new Point(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2);
    }

    public static function getBoundsCenter (d :DisplayObject) :Point
    {
        var bounds :Rectangle = d.getBounds(d);
        return new Point(bounds.left + bounds.width / 2, bounds.top + bounds.height / 2);
    }


    protected static function createBitmapData (disp :DisplayObject, width :int = -1,
        height :int = -1, uniformScale :Boolean = true) :BitmapData
    {
        var bounds :Rectangle = disp.getBounds(disp);

        if (width < 0) {
            width = bounds.width;
        }
        if (height < 0) {
            height = bounds.height;
        }

        var scaleX :Number = width / bounds.width;
        var scaleY :Number = height / bounds.height;
        if (uniformScale) {
            scaleX = scaleY = Math.min(scaleX, scaleY);
        }

        var bd :BitmapData = new BitmapData(width, height, true, 0);
        bd.draw(disp, new Matrix(scaleX, 0, 0, scaleY, -bounds.x * scaleX, -bounds.y * scaleY));
        return bd;
    }

    protected static const log :Log = Log.getLog(DisplayUtils);
}
}
