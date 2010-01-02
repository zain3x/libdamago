//
// $Id: LocalSubControlFake.as 4299 2009-08-05 22:35:33Z tim $

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.LocalSubControl;

import flash.geom.Point;
import flash.geom.Rectangle;
import flash.net.URLRequest;
import flash.net.navigateToURL;

public class LocalSubControlFake extends LocalSubControl
{
    public function LocalSubControlFake(parent :AbstractControl)
    {
        super(parent);
    }

    override public function locationToRoom (x :Number, y :Number, z :Number) :Point
    {
        var xMinFront :Number = 0;
        var xMaxFront :Number = 700;
        var xMinBack :Number = 50;
        var xMaxBack :Number = 600;

        return new Point(x*700, 500 - (z*240));
    }

    override public function locationToPaintable (x :Number, y :Number, z :Number) :Point
    {
        return locationToRoom(x, y, z);
    }

    override public function getRoomBounds () :Array
    {
        return FakeAVRGContext.roomBounds;
    }

    override public function getPaintableArea (full :Boolean = true) :Rectangle
    {
        return FakeAVRGContext.paintableArea;
    }

    override public function navigateToURL (url :Object, preferredTarget :String = null) :void
    {
        var urlReq :URLRequest =
            (url is URLRequest ? url as URLRequest : new URLRequest(url as String));
        flash.net.navigateToURL(urlReq, preferredTarget);
    }
}
}
