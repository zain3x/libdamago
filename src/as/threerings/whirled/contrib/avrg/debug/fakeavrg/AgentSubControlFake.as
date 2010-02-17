//
// $Id$

package com.threerings.whirled.contrib.avrg.debug.fakeavrg {

import com.whirled.AbstractControl;
import com.whirled.avrg.AgentSubControl;

public class AgentSubControlFake extends AgentSubControl
{
    public function AgentSubControlFake (ctrl :AbstractControl)
    {
        super(ctrl);
    }

    override public function sendMessage (name :String, value :Object = null) :void
    {
        MessageMgr.sendMessageTo(MessageMgr.agentChannel(), name, value, FakeAVRGContext.playerId);
    }
}

}
