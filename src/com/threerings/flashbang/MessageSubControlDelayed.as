//
// $Id: MessageSubControlDelayed.as 2467 2009-06-10 18:44:02Z nathan $

package com.whirled.contrib.simplegame{

import com.whirled.net.MessageSubControl;

public class MessageSubControlDelayed implements MessageSubControl
{
    public function MessageSubControlDelayed (playerId :int, sendMessageImpl :Function)
    {
        _playerId = playerId;
        _sendMessage = sendMessageImpl;
    }

    public function sendMessage (name:String, value:Object=null) :void
    {
        _sendMessage(_playerId, name, value);
    }
    protected var _sendMessage :Function;
    protected var _playerId :int;
}
}
