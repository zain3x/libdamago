package com.whirled.contrib.facebook.debug
{
import aduros.util.F;

import com.facebook.data.users.FacebookUser;
import com.threerings.display.DisplayUtil;
import com.threerings.ui.OrientationType;
import com.threerings.ui.SimpleScrollableArrayView;
import com.threerings.com.threerings.util.ArrayUtil;
import com.whirled.contrib.cache.BasicURLImageCache;
import com.whirled.contrib.facebook.connection.FacebookConnection;

import flash.display.Sprite;

public class TestFacebookDesktopSession extends Sprite
{
    public function TestFacebookDesktopSession()
    {
        _mugshots = new SimpleScrollableArrayView(OrientationType.HORIZONTAL, 300, 50);
        addChild(_mugshots);
        DisplayUtil.positionBounds(_mugshots, 10, 100);

        FacebookConnection.init(API_KEY, API_SECRET, null, null, false);
        FacebookConnection.whenFriendsLoaded(displayFriendMugshots);

        _imageCache.addEventListener(BasicURLImageCache.URL_DATA_LOADED,
            F.callback(_mugshots.redrawElements));

    }

    protected function displayFriendMugshots () :void
    {
        var friends :Array = FacebookConnection.friends;
        ArrayUtil.sortOn(friends, ["name"]);
        for each (var friend :FacebookUser in friends) {
            var picUrl :String = friend.pic_square;
            if (picUrl != null) {
                _mugshots.add(_imageCache.getBitmap(picUrl));
            }
        }
    }

    protected var _mugshots :SimpleScrollableArrayView;
    protected var _imageCache :BasicURLImageCache = new BasicURLImageCache(50);

    protected static const API_KEY :String = "920c377ed5fb3c1b3c4badbec6576543";
    protected static const API_SECRET :String = "1ebcf47182c8f76ba87bdba11c5cbe3d";
}
}
