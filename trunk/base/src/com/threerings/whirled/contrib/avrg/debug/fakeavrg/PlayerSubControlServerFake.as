//
// $Id: PlayerSubControlServerFake.as 2466 2009-06-10 18:19:11Z nathan $

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class PlayerSubControlServerFake extends PlayerSubControlServer
{
    public function PlayerSubControlServerFake (ctrl :AbstractControl, targetId :int)
    {
        super(ctrl, targetId);
    }

    override protected function handleUnload (event :Event) :void
    {
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function getPlayerName () :String
    {
        return "Player " + getPlayerId();
    }

    override public function awardTrophy (ident :String) :Boolean
    {
        return true;
    }

    override public function awardPrize (ident :String) :void
    {
    }

    override public function get props () :PropertySubControl
    {
        return _propsfake;
    }

    override public function sendMessage (name :String, value :Object = null) :void
    {
        MessageMgr.sendMessageTo(MessageMgr.playerChannel(getPlayerId()), name, value,
            FakeAVRGContext.SERVER_AGENT_ID);
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.playerPropSpace(getPlayerId()));
        return [ _propsfake ];
    }

    protected var _propsfake :PropertySubControl;
}

}
