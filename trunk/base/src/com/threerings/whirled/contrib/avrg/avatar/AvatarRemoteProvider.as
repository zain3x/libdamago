//
// $Id: AvatarRemoteProvider.as 2467 2009-06-10 18:44:02Z nathan $

package com.whirled.contrib.avrg.avatar{

import com.threerings.util.Log;
import com.whirled.AvatarControl;

public class AvatarRemoteProvider
{
    public function AvatarRemoteProvider(avatar :Object, ctrl :AvatarControl)
    {
        _avatar = avatar;
        _ctrl = ctrl;
    }

    public function propertyProvider (key :String) :Object
    {
        var prop :Object = _avatar[key] as Object;
        log.debug("propertyProvider", "key", key, "prop", prop);
        return prop;
    }

    protected var _avatar :Object;
    protected var _ctrl :AvatarControl;
    protected static const log :Log = Log.getLog(AvatarRemoteProvider);
}
}
