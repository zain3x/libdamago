//
// $Id: FacebookConnection.as 4688 2009-08-20 21:51:30Z nathan $

package com.whirled.contrib.facebook.connection{

import aduros.util.F;

import com.facebook.Facebook;
import com.facebook.commands.notifications.SendNotification;
import com.facebook.commands.stream.PublishPost;
import com.facebook.data.users.FacebookUser;
import com.facebook.events.FacebookEvent;
import com.facebook.net.FacebookCall;
import com.facebook.session.DesktopSession;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.avrg.AVRGameControl;
import com.whirled.contrib.DelayUtil;
import com.whirled.contrib.EventHandlerBase;
import com.whirled.contrib.ManagedTimer;
import com.whirled.contrib.TimerManager;

import flash.net.*;

/**
 * Wrapper around the Facebook-AS3 library.
 */
public class FacebookConnection extends EventHandlerBase
{
    public static function init (apiKey :String, secretKey :String, fbSessionKey :String,
        uid :String, autoLoadFriends :Boolean = true) :void
    {
        if (instance._connected || instance._waitingForLogin) {
            log.warning("init, but ", "_connected", instance._connected, "_waitingForLogin",
                instance._waitingForLogin);
            return;
        }

        _autoLoadFriends = autoLoadFriends;
        var params :FacebookParams = new FacebookParams(apiKey, secretKey, fbSessionKey, uid);
        instance.connect(params);
    }

    public static function get instance () :FacebookConnection
    {
        if (_facebookConnection == null) {
            _facebookConnection = new FacebookConnection();
        }
        return _facebookConnection;
    }

    public static function get friendIds () :Array
    {
        return FriendsModel.friendsIDArray;
    }

    public static function get friends () :Array
    {
        return friendIds.map(Util.adapt(getFriend));
    }

    public static function get loggedInUserID () :String
    {
        return instance.facebook.uid;
    }

    public static function getFriend (uid :String) :FacebookUser
    {
        return FriendsModel.getFriend(uid);
    }

    /**
     * Waits until the singleton FacebookConnection is connected before calling the zero-arg
     * callback function.
     */
    public static function whenConnected (callback :Function) :void
    {
        if (instance.isConnected) {
            callback();

        } else {
            instance.addEventListener(
                FacebookDataEvent.FACEBOOK_CONNECTED, F.justOnce(F.callback(callback)));
        }
    }

    public static function whenFriendsLoaded (callback :Function) :void
    {
        if (instance.friendsLoaded) {
            callback();

        } else {
            instance.addEventListener(
                FacebookDataEvent.FACEBOOK_FRIEND_DATA_ARRIVED, F.justOnce(F.callback(callback)));
        }
    }

    /**
     * Posts a FacebookCall to facebook.
     */
    public static function post (call :FacebookCall) :void
    {
        whenConnected(function () :void {
            call.addEventListener(FacebookEvent.COMPLETE,
                F.justOnce(function (e :FacebookEvent) :void {
                    log.info("post received complete event", "event", e);
                }));

            instance._facebook.post(call);
        });
    }

    public static function postMessage (msg :String) :void
    {
        var call :PublishPost = new PublishPost(msg);
        post(call);
    }

    //type = "user_to_user" or "app_to_user"
    public static function sendNotification (ids :Array, notification :String,
        callback :Function = null, type :String = "user_to_user") :void
    {
        var call :SendNotification = new SendNotification(ids, notification, type);
        if (callback != null) {
            // _events.registerOneShotCallback doesn't pass the event to the callback function.
            // That should probably be fixed at some point, but until then, F.justOnce does pass
            // it in, and performs the same cleanup service.
            call.addEventListener(FacebookEvent.COMPLETE, F.justOnce(callback));
        }
        post(call);
    }

    public function FacebookConnection ()
    {
        if (_facebookConnection != null) {
            throw new Error("Singleton class");
        }
    }

    public function get friendsLoaded () :Boolean
    {
        return _friendsLoaded;
    }

    public function get isWaitingForLogin () :Boolean
    {
        return _waitingForLogin;
    }

    public function get facebook () :Facebook
    {
        return _facebook;
    }

    public function get isConnected () :Boolean
    {
        return _connected;
    }

    public function loadFriends () :void
    {
        trace("Loading friends");
        FriendsModel.facebook = _facebook;
        FriendsModel.loggedInUserID = _facebook.uid;
        FriendsModel.loadFriends(
            function () :void {
                log.debug("Friend data loaded.");
                _friendsLoaded = true;
                instance.dispatchEvent(
                    new FacebookDataEvent(FacebookDataEvent.FACEBOOK_FRIEND_DATA_ARRIVED));

            },
            function () :void {
                log.warning("Failure to load friends, ATM doing nothing more");
            });
    }

    public function login () :void
    {
        _session.login(false);
    }

    public function refreshSession () :void
    {
        _facebook.refreshSession();
    }

    public function verifySession () :void
    {
        _session.verifySession();
    }

    override public function shutdown () :void
    {
        super.shutdown();
        _timerManager.shutdown();
    }

    protected function connect (params :FacebookParams) :void
    {
        _params = params;
        log.debug("connect", "params", params);
        _session = new FacebookSessionUtilMod(params.apiKey, params.secretKey, params.sessionKey,
            params.uid);
        _session.addEventListener(FacebookEvent.CONNECT, handleFacebookConnected);
        _session.addEventListener(FacebookEvent.WAITING_FOR_LOGIN, handleWaitingForLogin);
        _facebook = _session.facebook;

        var selfref :FacebookConnection = this;
        //If we're a DesktopSession, try logging in
        if (_session.activeSession is DesktopSession) {
            if (!_facebook.is_connected && !_facebook.waiting_for_login) {
                login();

                runUntil(_timerManager, REATTEMPT_LOGIN_INTERVAL_MS, F.adapt(login),
                    function () :Boolean {
                        return !selfref.isConnected;
                    });

//                _timerManager.runUntil(REATTEMPT_LOGIN_INTERVAL_MS, F.adapt(login),
//                function () :Boolean {
//                    return !selfref.isConnected;
//                });

            }
            function callback () :void {
                _facebook.refreshSession();
            }
            runUntil(_timerManager, REFRESH_SESSION_INTERVAL_MS, F.adapt(callback),
                function () :Boolean {
                    return !selfref.isConnected;
                }, F.adapt(loadFriends));
//            _timerManager.runUntil(REFRESH_SESSION_INTERVAL_MS, F.adapt(callback),
//                function () :Boolean {
//                    return !selfref.isConnected;
//                }, F.adapt(loadFriends));

        } else {

            runUntil(_timerManager, REFRESH_SESSION_INTERVAL_MS, _session.verifySession,
                function () :Boolean {
                    return !selfref.isConnected;
                }, F.adapt(loadFriends));


//            _timerManager.runUntil(REFRESH_SESSION_INTERVAL_MS, _session.verifySession,
//                function () :Boolean {
//                    return !selfref.isConnected;
//                }, F.adapt(loadFriends));

            _session.verifySession();
        }
    }

    protected function handleWaitingForLogin (e :FacebookEvent) :void
    {
        log.debug("Waiting for login...");
        _waitingForLogin = true;
    }

    protected function handleFacebookConnected (e :FacebookEvent) :void
    {
        log.debug("onConnect", "e", e, "error", e.error);
        if (_facebook.is_connected) {
            if (_autoLoadFriends) {
                loadFriends();
            }
            _waitingForLogin = false;
            _connected = true;
            dispatchEvent(new FacebookDataEvent(FacebookDataEvent.FACEBOOK_CONNECTED));

        } else {
            DelayUtil.delay(DelayUtil.SECONDS, 5, function () :void {
                log.warning("FacebookSession.validateLogin()");
                _facebook.refreshSession();
            });
        }
    }

    public static function runUntil (timer :TimerManager, delay :Number, callback :Function,
        check :Function, completeCallback :Function = null) :void
    {
        if (!check()) {
            return;
        }
        var timerMod :ManagedTimer = timer.runForever(delay, modCallback);
        function modCallback () :void {
            if (check()) {
                callback();
            } else {
                timerMod.cancel();
                if (completeCallback != null) {
                    completeCallback();
                }
            }
        }

    }

    protected var _timerManager :TimerManager = new TimerManager();
    protected var _facebook :Facebook;
    protected var _session :FacebookSessionUtilMod;
    protected var _connected :Boolean = false;
    protected var _friendsLoaded :Boolean = false;
    protected var _waitingForLogin :Boolean = false;
    protected var _params :FacebookParams;

    protected static var _autoLoadFriends :Boolean = false;
    protected static var _ctrl :AVRGameControl;
    protected static var _facebookConnection :FacebookConnection;

    protected static const UUID_CHARACTER_SPACE :String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    protected static const REFRESH_SESSION_INTERVAL_MS :Number = 2000;
    protected static const REATTEMPT_LOGIN_INTERVAL_MS :Number = 10000;

    protected static const log :Log = Log.getLog(FacebookConnection);
}
}
