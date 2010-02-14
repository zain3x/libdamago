//
// $Id$

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.PlayerSubControlClient;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class PlayerSubControlClientFake extends PlayerSubControlClient
{
    public function PlayerSubControlClientFake(ctrl:AbstractControl)
    {
        super(ctrl);
        MessageMgr.addMsgReceiver(MessageMgr.playerChannel(getPlayerId()), this);
    }

    override protected function handleUnload (event :Event) :void
    {
        MessageMgr.removeMsgReceiver(MessageMgr.playerChannel(getPlayerId()), this);
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function get props () :PropertySubControl
    {
        return _propsfake;
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.playerPropSpace(getPlayerId()));
        return [ _propsfake ];
    }

    override public function setUserProps (o :Object) :void
    {
    }

    override public function getPlayerId () :int
    {
        return FakeAVRGContext.playerId;
    }

    protected var _propsfake :PropertySubControl;
}
}
