//
// $Id: RoomSubControlClientFake.as 2466 2009-06-10 18:19:11Z nathan $

package com.whirled.contrib.avrg.debug.fakeavrg{

import com.threerings.util.ArrayUtil;
import com.whirled.AbstractControl;
import com.whirled.avrg.AVRGameAvatar;
import com.whirled.avrg.RoomSubControlClient;
import com.whirled.net.PropertyGetSubControl;
import com.whirled.net.PropertySubControl;

import flash.events.Event;

public class RoomSubControlClientFake extends RoomSubControlClient
{
    public function RoomSubControlClientFake(ctrl:AbstractControl, targetId:int=0)
    {
        super(ctrl, targetId);
        MessageMgr.addMsgReceiver(MessageMgr.roomChannel(getRoomId()), this);
    }

    override protected function handleUnload (event :Event) :void
    {
        MessageMgr.addMsgReceiver(MessageMgr.roomChannel(getRoomId()), this);
        PropsMgr.destroyPropCtrl(_propsfake);
        super.handleUnload(event);
    }

    override public function get props () :PropertyGetSubControl
    {
        return _propsfake;
    }

    override public function getPlayerIds () :Array
    {
        return FakeAVRGContext.playerIds;
    }

    override public function getEntityIds (type :String = null) :Array
    {
        return FakeAVRGContext.entityIds;
    }

    override public function getEntityProperty (key :String, entityId :String = null) :Object
    {
        var index :int = ArrayUtil.indexOf(FakeAVRGContext.entityIds, entityId);
        return FakeAVRGContext.playerIds[index];
    }

    override protected function createSubControls () :Array
    {
        _propsfake = PropsMgr.createPropCtrl(_parent, PropsMgr.roomPropSpace(getRoomId()));
        return [ _propsfake ];
    }

    override public function setUserProps (o :Object) :void
    {
    }

    override public function getAvatarInfo(playerId :int) :AVRGameAvatar
    {
        var avatar :AVRGameAvatar = new AVRGameAvatar();
        avatar.x = 100;
        avatar.y = 100;
        avatar.z = 100;
        return avatar;
    }

    protected var _propsfake :PropertySubControl;
}
}
