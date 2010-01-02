//
// $Id: RoomSubControlServerFake.as 2466 2009-06-10 18:19:11Z nathan $

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class RoomSubControlServerFake extends RoomSubControlServer
{
    public function RoomSubControlServerFake (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    override protected function handleUnload (event :Event) :void
    {
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function get props () :PropertySubControl
    {
        return _propsfake;
    }

    override public function sendMessage (name :String, value :Object = null) :void
    {
        MessageMgr.sendMessageTo(MessageMgr.roomChannel(getRoomId()), name, value,
            FakeAVRGContext.SERVER_AGENT_ID);
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.roomPropSpace(getRoomId()));
        return [ _propsfake ];
    }

    protected var _propsfake :PropertySubControl;
}

}
