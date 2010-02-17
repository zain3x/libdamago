//
// $Id$

package com.threerings.facebook
{

import flash.events.Event;

public class FacebookDataEvent extends Event
{
    public static const FACEBOOK_FRIEND_DATA_ARRIVED :String = "facebookFriendData";
    public static const FACEBOOK_CONNECTED :String = "facebookConnected";

    public function FacebookDataEvent (type :String)
    {
        super(type, false, false);
    }
}
}
