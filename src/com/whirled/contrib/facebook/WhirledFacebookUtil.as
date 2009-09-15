package com.whirled.contrib.facebook
{
import com.threerings.util.Log;
import com.whirled.avrg.AVRGameControl;


/**
 * Wrapper around the Facebook-AS3 library.
 *
 * For use in Whirled embedded Facebook games only.
 *
 */
public class WhirledFacebookUtil
{
    /**
     * Creates a FacebookConnection using Whirled.
     */
    public static function initFacebookConnection (ctrl :AVRGameControl, apiKey :String,
        autoLoadFriends :Boolean = true) :void
    {
        var instance :FacebookConnection = FacebookConnection.instance;
        if (instance.isConnected || instance.isWaitingForLogin) {
            log.warning("init, but ", "_connected", instance.isConnected, "_waitingForLogin",
                instance.isWaitingForLogin);
            return;
        }

        //Get the session key and player UID from the AVRGameControl.player
        var fbSessionKey :String = null;
        var uid :String = null;
        if (ctrl.player.getFacebookInfo() != null) {
            uid = ctrl.player.getFacebookInfo()[0] as String;
            fbSessionKey = ctrl.player.getFacebookInfo()[1] as String;
        } else {
            log.error("No FacebookInfo on PlayerSubControl, sessionKey==null");
        }
        log.debug("fbSessionKey=" + fbSessionKey);

        FacebookConnection.init(apiKey, null, fbSessionKey, uid, autoLoadFriends);
    }

    protected static const log :Log = Log.getLog(WhirledFacebookUtil);
}
}