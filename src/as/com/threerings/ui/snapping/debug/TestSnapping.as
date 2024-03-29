package com.threerings.ui.snapping.debug
{
import com.threerings.display.DisplayUtil;
import com.threerings.ui.bounds.BoundsPolygon;
import com.threerings.ui.bounds.BoundsRectangle;
import com.threerings.ui.snapping.ISnapAnchor;
import com.threerings.ui.snapping.SnapAnchorBoundsExclude;
import com.threerings.ui.snapping.SnapAnchorPoint;
import com.threerings.ui.snapping.SnapAnchorRect;
import com.threerings.ui.snapping.SnapManager;
import com.threerings.ui.snapping.SnapType;
import com.threerings.ui.snapping.SnappingObject;

import flash.display.Graphics;
import flash.display.Sprite;
import flash.geom.Point;
import flash.geom.Rectangle;

import com.threerings.geometry.Polygon;


public class TestSnapping extends Sprite
{
    public function TestSnapping()
    {
        var snapper :SnapManager = new SnapManager(this);

        var locX :Number = 100;
        var locY :Number = 100;
        var gap :Number = 100;
        var ii :int;
        var size :int = 22;
        var anc :ISnapAnchor;
        for (ii = 0; ii < 1; ++ii) {
            var blobAnchor :Sprite = new Sprite();
            blobAnchor.x = locX;
            blobAnchor.y = locY;
            drawDot(blobAnchor, 0x00ff00, size, 0, 0);
            addChild(blobAnchor);
            anc = new SnapAnchorPoint(new Point(locX, locY));
            snapper.addAnchor(anc);
            locX += gap + 100;
        }

        for (ii = 0; ii < 1; ++ii) {
            var rect :Sprite = new Sprite();
            drawRect(rect, 200, 200, 0x00ff00);
            rect.x = locX;
            rect.y = locY;
            addChild(rect);
            anc = new SnapAnchorRect(new Rectangle(locX, locY, rect.width, rect.height));
            snapper.addAnchor(anc);
            locX += gap + 300;
        }

        for (ii = 0; ii < 1; ++ii) {
            var poly :Polygon = Polygon.createPolygon(5, 60);
            poly.translateLocal(locX, locY);
            poly.draw(this.graphics, 0x00ff00);
            anc = new SnapAnchorBoundsExclude(new BoundsPolygon(poly));
            snapper.addAnchor(anc);
            locX += gap;
        }




        var blob :Sprite = new Sprite();
        blob.x = 10;
        blob.y = 10;
        var outerblob :Sprite = new Sprite();
        outerblob.addChild(blob);
        drawDot(blob, 0xffffff, 20);
        drawDot(outerblob, 0x00ffff, 25, 20, 20);
        outerblob.x = 300;
        outerblob.y = 300;
        addChild(outerblob);
        var snapping :SnappingObject = new SnappingObject(outerblob, BoundsRectangle.fromRectangle(
            blob.getBounds(outerblob)));
        snapping.localBounds.debugDraw((snapping.displayObject as Sprite));

        snapper.beginSnapping(snapping);

    }

    protected static function createRect (locX :Number = 0, locY :Number = 0) :Sprite
    {
        var size :Number = 40;
        var s :Sprite = new Sprite();
        var rect :Sprite = new Sprite();

        fillRect(rect, size, size);
        s.addChild(rect);
        DisplayUtil.positionBoundsRelative(rect, s, -size / 2, -size / 2);
        s.x = locX;
        s.y = locY;
        return s;
    }

    public static function drawDot (s :Sprite, color :int = 0x00ffff, r :Number = 10,
        x :int = 0, y :int = 0) :void
    {
        var g :Graphics = s.graphics;
        g.beginFill(color);
        g.drawCircle(x,y,r);
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
        g.beginFill(color, alpha);
        g.drawRect(0, 0, width, height);
        g.endFill();
    }
}
}
