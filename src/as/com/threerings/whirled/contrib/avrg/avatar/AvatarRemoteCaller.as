//
// $Id$

package com.threerings.whirled.contrib.avrg.avatar {

import com.threerings.util.Log;
import com.whirled.EntityControl;
import com.whirled.avrg.AVRGameControl;
import com.whirled.avrg.RoomSubControlClient;

public class AvatarRemoteCaller
{
    public function AvatarRemoteCaller (ctrl :AVRGameControl, playerId :int)
    {
        _ctrl = ctrl;
        _playerId = playerId;
    }

    public function apply (handler :String, ... args) :Object
    {
        var entityId :String = getAvatarEntityId(_ctrl.room, _playerId);
        if (entityId == null) {
            log.error("apply", "playerId", _playerId, "entityId", entityId);
            return null;
        }

        var prop :Object = _ctrl.room.getEntityProperty(handler, entityId);
        if (prop == null) {
            log.error("apply", "playerId", _playerId, "entityId", entityId, "prop", prop);
            return null;
        }

        if (prop is Function) {
            try {
                var f :Function = prop as Function;
                return f.apply(f, args);

            } catch (err :Error) {
                log.error("apply", "playerId", _playerId, "entityId", entityId, "prop", prop);
                log.error("error=" + err);
            }
        }
        return prop;
    }

    protected static function getAvatarEntityId (ctrl :RoomSubControlClient, userId :int) :String
    {
        for each (var entityId :String in ctrl.getEntityIds(EntityControl.TYPE_AVATAR)) {
            var entityUserId :int =
                int(ctrl.getEntityProperty(EntityControl.PROP_MEMBER_ID, entityId));
            if (userId == entityUserId) {
                return entityId
            }
        }
        return null;
    }

    protected var _ctrl :AVRGameControl;
    protected var _playerId :int;
    protected static const log :Log = Log.getLog(AvatarRemoteCaller);
}
}
