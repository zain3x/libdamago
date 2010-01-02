//
// $Id: AVRServerGameControlFake.as 4127 2009-07-30 22:22:40Z tim $

package com.whirled.contrib.avrg.debug.fakeavrg{

import com.threerings.util.MethodQueue;
import com.whirled.avrg.AVRGameControlEvent;
import com.whirled.avrg.AVRServerGameControl;
import com.whirled.avrg.PlayerSubControlServer;
import com.whirled.avrg.RoomSubControlServer;
import com.whirled.net.PropertySubControl;

import flash.display.DisplayObject;

public class AVRServerGameControlFake extends AVRServerGameControl
{
    /**
     * Creates a new game control for a server agent.
     */
    public function AVRServerGameControlFake (serv :DisplayObject)
    {
        super(serv);
        FakeAVRGContext.server = this;
    }

    public function addPlayer (ctrl :AVRGameControlFake) :void
    {
        playerJoinedGame_v1(ctrl.player.getPlayerId());
    }

    override public function getRoom (roomId :int) :RoomSubControlServer
    {
        var ctrl :RoomSubControlServerFake = _roomControls[roomId];
        if (ctrl == null) {
            // This throws an error if the room isn't loaded
            ctrl = new RoomSubControlServerFake(this, roomId);
            ctrl.gotHostProps(_funcs);
            _roomControls[roomId] = ctrl;
        }
        return ctrl;
    }

    override public function getPlayer (playerId :int) :PlayerSubControlServer
    {
        var ctrl :PlayerSubControlServerFake = _playerControls[playerId];
        if (ctrl == null) {
            // This throws an error if the player isn't loaded
            ctrl = new PlayerSubControlServerFake(this, playerId);
            ctrl.gotHostProps(_funcs);
            _playerControls[playerId] = ctrl;
        }
        return ctrl;
    }

    override public function loadOfflinePlayer (playerId :int, success :Function, failure :Function)
        :void
    {
        MethodQueue.callLater(function () :void {
            failure("This isn't a real server!");
        });
    }

    override public function get props () :PropertySubControl
    {
        return _fakeprops;
    }

    override protected function createSubControls () :Array
    {
        return [
            _fakeprops = PropsMgr.createPropCtrl(this, "server_private"),
            _game = new GameSubControlServerFake(this),
        ];
    }

    override protected function getPlayerProps (playerId :int) :PropertySubControl
    {
        return getPlayer(playerId).props;
    }

    override protected function playerJoinedGame_v1 (playerId :int) :void
    {
        game.dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_JOINED_GAME, null, playerId));
    }

    /** @private */
    override protected function playerLeftGame_v1 (playerId :int) :void
    {
        game.dispatchEvent(new AVRGameControlEvent(
            AVRGameControlEvent.PLAYER_QUIT_GAME, null, playerId));
        delete _playerControls[playerId];
    }

    /** @private */
    override protected function relayTo (getObj :Function, fun :String) :Function
    {
        return function (targetId :int, ... args) :* {
            // fetch the relevant subcontrol
            var obj :Object = getObj(targetId);
            // early-development sanity checks
            if (obj == null) {
                throw new Error("failed to find subcontrol [targetId=" + targetId + "]");
            }
            if (obj[fun] == null) {
                throw new Error("failed to find function in subcontrol [targetId=" +
                                targetId + ", fun=" + fun + "]");
            }
            // call the right function on it
            return obj[fun].apply(obj, args);
        };
    }

    protected var _fakeprops :PropertySubControl;
}

}
