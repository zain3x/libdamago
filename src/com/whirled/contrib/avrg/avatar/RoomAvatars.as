//
// $Id: RoomAvatars.as 4745 2009-08-24 19:29:37Z nathan $

package com.whirled.contrib.avrg.avatar{

import com.threerings.com.threerings.util.ArrayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.Util;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.AVRGamePlayerEvent;
import com.whirled.avrg.AVRGameRoomEvent;
import com.whirled.contrib.EventHandlerManager;

/**
 * Manages AvatarProxys.
 */
public class RoomAvatars
{
    public static function init (ctrl :AVRGameControl) :void
    {
        _ctrl = ctrl;
        _events = new EventHandlerManager();
        _events.registerUnload(ctrl);

        _events.registerListener(_ctrl.room, AVRGameRoomEvent.PLAYER_ENTERED, updateRoom);
        _events.registerListener(_ctrl.room, AVRGameRoomEvent.PLAYER_LEFT, updateRoom);

        _events.registerListener(_ctrl.player, AVRGamePlayerEvent.ENTERED_ROOM, updateRoom);
        _events.registerListener(_ctrl.player, AVRGamePlayerEvent.LEFT_ROOM, updateRoom);

        updateRoom();
    }

    public static function getAvatarProxy (playerId :int) :AvatarProxy
    {
        if (!_playerId2AvatarProxy.containsKey(playerId) &&
            ArrayUtil.contains(_ctrl.room.getPlayerIds(), playerId)) {

            _playerId2AvatarProxy.put(playerId, new AvatarProxy(_ctrl, playerId));
        }
        return _playerId2AvatarProxy.get(playerId) as AvatarProxy;
    }

    protected static function updateRoom (...ignored) :void
    {
        if (_ctrl.room.getRoomId() == 0) {
            // we're not in a room
            return;
        }

        var playerIds :Array = _ctrl.room.getPlayerIds();
        playerIds.push(_ctrl.player.getPlayerId());

        var avatarIds :Array = _playerId2AvatarProxy.keys();
        //Remove proxy avatars not in room.
        avatarIds.forEach(Util.adapt(function (playerId :int) :void {
            if (!ArrayUtil.contains(playerIds, playerId)) {
                _playerId2AvatarProxy.remove(playerId);
            }
        }));

        for each (var playerId :int in playerIds) {
            if (!_playerId2AvatarProxy.containsKey(playerId)) {
                _playerId2AvatarProxy.put(playerId, new AvatarProxy(_ctrl, playerId));
            }
        }

    }

    protected static var _ctrl :AVRGameControl;
    protected static var _playerId2AvatarProxy :Map = Maps.newMapOf(int);
    protected static var _events :EventHandlerManager;
}
}
