package com.threerings.ui.snapping.debug
{
import com.threerings.debug.DebugUtil;
import com.threerings.display.DisplayUtil;
import com.threerings.ui.snapping.SnapAxis;
import com.threerings.ui.snapping.SnapManager;

import flash.display.Sprite;
import flash.geom.Point;


public class TestSnapping extends Sprite
{
    public function TestSnapping()
    {
        var snapper :SnapManager = new SnapManager(this);

        var locX :Number = 100;
        var locY :Number = 100;
        var gap :Number = 100;
        var ii :int;
        for (ii = 0; ii < 2; ++ii) {
            var blobAnchor :Sprite = new Sprite();
            DebugUtil.drawDot(blobAnchor.graphics, 0x00ff00, 22, locX, locY);
            addChild(blobAnchor);
            snapper.addPointAnchor(blobAnchor);
            locX += gap;
        }

        for (ii = 0; ii < 1; ++ii) {
            var rect :Sprite = new Sprite();
            DebugUtil.drawRect(rect, 30, 150, 0x00ff00);
            rect.x = locX;
            rect.y = locY;
            addChild(rect);
            snapper.addRectAnchor(rect, SnapAxis.X_AND_Y);
            locX += gap;

        }

        var blob :Sprite = new Sprite();
        blob.x = 10;
        blob.y = 10;
        var outerblob :Sprite = new Sprite();
        outerblob.addChild(blob);
        DebugUtil.drawDot(blob.graphics, 0xffffff, 20);
        DebugUtil.drawDot(outerblob.graphics, 0x00ffff, 25);
        outerblob.x = 300;
        outerblob.y = 300;
        addChild(outerblob);
        snapper.addSnappable(blob, outerblob);
    }

    protected static function createRect (locX :Number = 0, locY :Number = 0) :Sprite
    {
        var size :Number = 40;
        var s :Sprite = new Sprite();
        var rect :Sprite = new Sprite();

        DebugUtil.fillRect(rect, size, size);
        s.addChild(rect);
        DisplayUtil.positionBoundsRelative(rect, s, -size / 2, -size / 2);
        s.x = locX;
        s.y = locY;
        return s;
    }
}
}