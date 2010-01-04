//
// $Id$

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.threerings.util.ArrayUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;
import com.threerings.util.MethodQueue;
import com.whirled.game.client.PropertySpaceHelper;
import com.whirled.net.MessageReceivedEvent;

import flash.events.IEventDispatcher;
import flash.utils.ByteArray;

public class MessageMgr
{
    public static function agentChannel () :String
    {
        return "Agent";
    }

    public static function playerChannel (playerId :int) :String
    {
        return "Player_" + playerId;
    }

    public static function gameChannel () :String
    {
        return "Game";
    }

    public static function roomChannel (roomId :int) :String
    {
        return "Room_" + roomId;
    }

    public static function sendMessageTo (channelName :String, name :String, val :Object,
        senderId :int) :void
    {
        var encoded :Object = PropertySpaceHelper.encodeProperty(val, true);
        var decoded :Object = PropertySpaceHelper.decodeProperty(encoded);
        var f :Function = function () :void {
            for each (var receiver :IEventDispatcher in getChannelReceivers(channelName)) {
                receiver.dispatchEvent(new MessageReceivedEvent(name, decoded, senderId));
            }
        };

        MethodQueue.callLater(f);
    }

    public static function addMsgReceiver (channelName :String, receiver :IEventDispatcher) :void
    {
        var receivers :Array = getChannelReceivers(channelName);
        receivers.push(receiver);
    }

    public static function removeMsgReceiver (channelName :String, receiver :IEventDispatcher) :void
    {
        var receivers :Array = getChannelReceivers(channelName);
        ArrayUtil.removeFirst(receivers, receiver);
    }

    protected static function getChannelReceivers (channelName :String) :Array
    {
        var receivers :Array = _msgChannels.get(channelName);
        if (receivers == null) {
            receivers = [];
            _msgChannels.put(channelName, receivers);
        }

        return receivers;
    }

    // Map<name, Array<IEventDispatcher>>
    protected static var _msgChannels :Map = Maps.newMapOf(String);
}
}
