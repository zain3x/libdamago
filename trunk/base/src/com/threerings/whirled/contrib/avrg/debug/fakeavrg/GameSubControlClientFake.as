//
// $Id: GameSubControlClientFake.as 2466 2009-06-10 18:19:11Z nathan $

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.GameSubControlClient;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class GameSubControlClientFake extends GameSubControlClient
{
    public function GameSubControlClientFake (ctrl :AbstractControl)
    {
        super(ctrl);
        MessageMgr.addMsgReceiver(MessageMgr.gameChannel(), this);
    }

    override protected function handleUnload (event :Event) :void
    {
        MessageMgr.removeMsgReceiver(MessageMgr.gameChannel(), this);
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function setUserProps (o :Object) :void
    {
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.gamePropSpace());
        return [ _propsfake ];
    }

    override public function get props () :PropertyGetSubControl
    {
        return _propsfake;
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
