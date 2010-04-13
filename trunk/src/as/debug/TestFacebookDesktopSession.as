package debug
{
import com.threerings.util.F;

import com.facebook.data.users.FacebookUser;
import com.threerings.display.DisplayUtil;
import com.threerings.facebook.FacebookConnection;
import com.threerings.ui.OrientationType;
import com.threerings.ui.SimpleScrollableArrayView;
import com.threerings.util.ArrayUtil;

import flash.display.DisplayObject;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.net.URLRequest;
import flash.system.LoaderContext;

public class TestFacebookDesktopSession extends Sprite
{
    public function TestFacebookDesktopSession()
    {
        _mugshots = new SimpleScrollableArrayView(OrientationType.HORIZONTAL, 300, 50);
        addChild(_mugshots);
        DisplayUtil.positionBounds(_mugshots, 10, 100);

        FacebookConnection.init(API_KEY, API_SECRET, null, null, false);
        FacebookConnection.whenFriendsLoaded(displayFriendMugshots);

    }

    protected function displayFriendMugshots () :void
    {
        var friends :Array = FacebookConnection.friends;
        ArrayUtil.sortOn(friends, ["name"]);
        for each (var friend :FacebookUser in friends) {
            var picUrl :String = friend.pic_square;
            if (picUrl != null) {
                _mugshots.add(loadPicFromUrl(picUrl));
            }
        }
    }

    protected static function loadPicFromUrl (url :String) :Sprite
    {
        var pic :Sprite = new Sprite();
        var imageLoader :Loader = new Loader();
        var loaderContext :LoaderContext = new LoaderContext();
        loaderContext.checkPolicyFile = true;

        var request :URLRequest = new URLRequest(url);
        imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE,
            F.justOnce(F.callback(onComplete)));
        imageLoader.load(request, loaderContext);

        function onComplete () :void {
            if (imageLoader.content != null && imageLoader.content is DisplayObject) {
                pic.addChild(imageLoader.content as DisplayObject);
            }
        }
        return pic;
    }

    protected var _mugshots :SimpleScrollableArrayView;

    protected static const API_KEY :String = "920c377ed5fb3c1b3c4badbec6576543";
    protected static const API_SECRET :String = "1ebcf47182c8f76ba87bdba11c5cbe3d";
}
}
