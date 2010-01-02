//
// $Id: FakeAVRGContext.as 2466 2009-06-10 18:19:11Z nathan $

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import flash.geom.Rectangle;

public class FakeAVRGContext
{
    public static var server :AVRServerGameControlFake;

    public static var playerId :int = 1;
    public static var playerIds :Array = [ 1 ];
    public static var entityIds :Array = ["R1:E1", "R1:E2", "R1:E3"];
    public static var roomBounds :Array = [700, 500];
    public static var paintableArea :Rectangle = new Rectangle(0, 0, 750, 550);
    public static const SERVER_AGENT_ID :int = int.MIN_VALUE;
}

}
