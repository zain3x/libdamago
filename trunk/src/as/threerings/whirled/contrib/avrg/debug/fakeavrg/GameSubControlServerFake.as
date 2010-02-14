//
// $Id$

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.GameSubControlServer;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class GameSubControlServerFake extends GameSubControlServer
{
    public function GameSubControlServerFake (ctrl :AbstractControl)
    {
        super(ctrl);
        MessageMgr.addMsgReceiver(MessageMgr.gameChannel(), this);
        MessageMgr.addMsgReceiver(MessageMgr.agentChannel(), this);
    }

    override protected function handleUnload (event :Event) :void
    {
        MessageMgr.removeMsgReceiver(MessageMgr.gameChannel(), this);
        MessageMgr.removeMsgReceiver(MessageMgr.agentChannel(), this);
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function get props () :PropertySubControl
    {
        return _propsfake;
    }

    override public function sendMessage (name :String, value :Object = null) :void
    {
        MessageMgr.sendMessageTo(MessageMgr.gameChannel(), name, value,
            FakeAVRGContext.SERVER_AGENT_ID);
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.gamePropSpace());
        return [ _propsfake ];
    }

    override public function getPlayerIds () :Array
    {
        return FakeAVRGContext.playerIds;
    }

    override public function getOccupantName (playerId :int) :String
    {
        return "Player " + playerId;
    }

    override public function getPartyIds () :Array /* of int */
    {
        return [];
    }

    override public function getLevelPacks () :Array
    {
        return [];
    }

    override public function getItemPacks () :Array
    {
        return [];
    }

    protected var _propsfake :PropertySubControl;
}

}
