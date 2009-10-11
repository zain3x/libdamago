//
// $Id$

package com.threerings.facebook {
import com.facebook.Facebook;
import com.facebook.commands.friends.GetFriends;
import com.facebook.commands.users.GetInfo;
import com.facebook.data.friends.GetFriendsData;
import com.facebook.data.users.FacebookUser;
import com.facebook.data.users.FacebookUserCollection;
import com.facebook.data.users.GetInfoData;
import com.facebook.data.users.GetInfoFieldValues;
import com.facebook.events.FacebookEvent;
import flash.events.EventDispatcher;
import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.threerings.util.DelayUtil;
/**
 * Modified from the StreamDemo in the Facebook examples.
 * Get and store friend Ids, get friend info (pics, gender, etc).
 */
public class FriendsModel extends EventDispatcher
{

    public static function getFriend (uid :String) :FacebookUser
    {
        return getInstance().getFriend(uid);
    }
    public static function getInstance () :FriendsModel
    {
        if (_instance == null) {
            _canInit = true;
            _instance = new FriendsModel();
            _canInit = false;
        }
        return _instance;
    }

    public static function loadFriends (loadedCallback :Function, failureCallback :Function) :void
    {
        getInstance()._onFriendsDataLoadedCallback = loadedCallback;
        getInstance()._onFriendsDataFailureCallback = failureCallback;
        getInstance().loadFriends();
    }

    public function FriendsModel ()
    {
        _friendsIDArray = [];
        _friendsHash = {};
        _pendingGetInfoIds = [];
        //These are the fields we are interested in
        //TODO pass these as a parameter?
        _getInfoFields = [ GetInfoFieldValues.NAME, GetInfoFieldValues.PIC_SQUARE,
            GetInfoFieldValues.SEX, GetInfoFieldValues.IS_APP_USER ];
    }

    protected function getFriend (uid :String) :FacebookUser
    {
        if (_friendsHash[uid]) {
            return _friendsHash[uid];
        } else {
            //Add any new Friend id's to a que, and load them all in half a second or so.
            DelayUtil.delay(DelayUtil.FRAMES, 15, requestFriendsList);

            var fbUser :FacebookUser = new FacebookUser();
            fbUser.uid = uid;
            _friendsHash[uid] = fbUser;

            _pendingGetInfoIds.push(uid);

            return fbUser;
        }
    }

    protected function getFriendsInfo () :void
    {
        var getInfoCall :GetInfo = new GetInfo(friendsIDArray, _getInfoFields);
        getInfoCall.addEventListener(FacebookEvent.COMPLETE, onFriendDataLoaded);

        _facebook.post(getInfoCall);
    }

    protected function loadFriends () :void
    {
        if (_getFriendsCall) {
            _getFriendsCall.delegate.close();
        }
        _getFriendsCall = new GetFriends();

        _getFriendsCall.addEventListener(FacebookEvent.COMPLETE, onGetFriends, false, 0, true);
        _facebook.post(_getFriendsCall);
    }

    //The intial load handler
    protected function onFriendDataLoaded (event :FacebookEvent) :void
    {
        var data :GetInfoData = (event.data as GetInfoData);
        onGetInfo(data);
        log.debug("onInitialUserInfoComplete", event);
        if (getInstance()._onFriendsDataLoadedCallback != null) {
            getInstance()._onFriendsDataLoadedCallback();
        }
    }

    protected function onGetFriends (event :FacebookEvent) :void
    {
        log.debug("onGetFriends", "event", event);
        if (event.success == false) {
            log.error('Error loading your friends.', 'Error');
            if (_onFriendsDataFailureCallback != null) {
                _onFriendsDataFailureCallback();
            }
        } else {
            var fbUsers :FacebookUserCollection = (event.data as GetFriendsData).friends;
            var l :uint = fbUsers.length;
            _friendsIDArray = [];
            var fbUser :FacebookUser;

            for (var i :uint = 0; i < l; i++) {
                fbUser = (fbUsers.getItemAt(i) as FacebookUser);
                _friendsIDArray.push(fbUser.uid);
                _friendsHash[fbUser.uid] = fbUser;
            }

            getFriendsInfo();
        }
    }

    protected function onGetInfo (data :GetInfoData) :void
    {
        if (data == null) {
            log.error("onGetInfo", "data", data);
            return;
        }
        var newUsers :FacebookUserCollection = data.userCollection;
        var l :uint = newUsers.length;
        var user :FacebookUser;
        var localUser :FacebookUser
        var fieldsLength :uint;

        for (var i :uint = 0; i < l; i++) {
            user = newUsers.getItemAt(i) as FacebookUser;
            //This is terribly brittle.
            //We just assume the order of the newUsers is the same as our friendsIdArray
            //since we don't get the UID with the results.
            localUser = _friendsHash[friendsIDArray[i]]; //user.uid
            if (localUser == null) {
                continue;
            }
            fieldsLength = _getInfoFields.length;
            while (fieldsLength--) {
                var fld :String = _getInfoFields[fieldsLength];
                //Update our local user with new info, bindings will notify all of changes.
                localUser[fld] = user[fld];
            }
        }
    }

    protected function onGetUserInfo (event :FacebookEvent) :void
    {
        if (event.success) {
            onGetInfo(event.data as GetInfoData);
        }
    }

    protected function requestFriendsList () :void
    {
        var getInfoCall :GetInfo = new GetInfo(_pendingGetInfoIds.slice(), _getInfoFields);
        getInfoCall.addEventListener(FacebookEvent.COMPLETE, onGetUserInfo, false, 0, true);
        _facebook.post(getInfoCall);

        _pendingGetInfoIds = [];
    }
    protected var _facebook :Facebook;
    protected var _friendsHash :Object;

    protected var _friendsIDArray :Array;
    protected var _getFriendsCall :GetFriends;
    protected var _getInfoFields :Array;
    protected var _loggedInUserID :String;
    protected var _onFriendsDataFailureCallback :Function;

    protected var _onFriendsDataLoadedCallback :Function;

    protected var _pendingGetInfoIds :Array;
    protected static var _canInit :Boolean = false;

    protected static var _instance :FriendsModel;

    protected static const log :Log = Log.getLog(FriendsModel);

    public static function set facebook (value :Facebook) :void
    {
        getInstance()._facebook = value;
    }

    public static function get friendsIDArray () :Array
    {
        return getInstance()._friendsIDArray;
    }

    public static function get loggedInUserID () :String
    {
        return getInstance()._loggedInUserID;
    }

    public static function set loggedInUserID (value :String) :void
    {
        getInstance()._loggedInUserID = value;
    }
}

}
