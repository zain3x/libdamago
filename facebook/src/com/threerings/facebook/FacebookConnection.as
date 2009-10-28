//
// $Id: FacebookConnection.as 4688 2009-08-20 21:51:30Z nathan $

package com.threerings.facebook {
import aduros.util.F;

import com.facebook.Facebook;
import com.facebook.commands.notifications.SendNotification;
import com.facebook.commands.stream.PublishPost;
import com.facebook.data.users.FacebookUser;
import com.facebook.events.FacebookEvent;
import com.facebook.net.FacebookCall;
import com.facebook.session.DesktopSession;
import com.threerings.util.DelayUtil;
import com.threerings.util.Log;
import com.threerings.util.Util;
import com.whirled.contrib.EventHandlerBase;



/**
 * Wrapper around the Facebook-AS3 library.
 */
public class FacebookConnection extends EventHandlerBase
{

    public static function getFriend (uid :String) :FacebookUser
    {
        return FriendsModel.getFriend(uid);
    }

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

    public static function runUntil (timer :TimerManager, delay :Number, callback :Function,
        check :Function, completeCallback :Function = null) :void
    {
        if (!check()) {
            return;
        }
        var timerMod :ManagedTimerImpl = timer.runForever(delay, modCallback);
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

    //type = "user_to_user" or "app_to_user"
    public static function sendNotification (ids :Array, notification :String, callback :Function =
        null, type :String = "user_to_user") :void
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

    /**
     * Waits until the singleton FacebookConnection is connected before calling the zero-arg
     * callback function.
     */
    public static function whenConnected (callback :Function) :void
    {
        if (instance.isConnected) {
            callback();

        } else {
            instance.addEventListener(FacebookDataEvent.FACEBOOK_CONNECTED,
                F.justOnce(F.callback(callback)));
        }
    }

    public static function whenFriendsLoaded (callback :Function) :void
    {
        if (instance.friendsLoaded) {
            callback();

        } else {
            instance.addEventListener(FacebookDataEvent.FACEBOOK_FRIEND_DATA_ARRIVED,
                F.justOnce(F.callback(callback)));
        }
    }

    public function FacebookConnection ()
    {
        if (_facebookConnection != null) {
            throw new Error("Singleton class");
        }
    }

    public function get facebook () :Facebook
    {
        return _facebook;
    }

    public function get friendsLoaded () :Boolean
    {
        return _friendsLoaded;
    }

    public function get isConnected () :Boolean
    {
        return _connected;
    }

    public function get isWaitingForLogin () :Boolean
    {
        return _waitingForLogin;
    }

    public function loadFriends () :void
    {
        trace("Loading friends");
        FriendsModel.facebook = _facebook;
        FriendsModel.loggedInUserID = _facebook.uid;
        FriendsModel.loadFriends(function () :void {
                log.debug("Friend data loaded.");
                _friendsLoaded = true;
                instance.dispatchEvent(new FacebookDataEvent(FacebookDataEvent.
                    FACEBOOK_FRIEND_DATA_ARRIVED));

            }, function () :void {
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
            DelayUtil.delayFrames(5*30, function () :void {
                    log.warning("FacebookSession.validateLogin()");
                    _facebook.refreshSession();
                });
        }
    }

    protected function handleWaitingForLogin (e :FacebookEvent) :void
    {
        log.debug("Waiting for login...");
        _waitingForLogin = true;
    }
    protected var _connected :Boolean = false;
    protected var _facebook :Facebook;
    protected var _friendsLoaded :Boolean = false;
    protected var _params :FacebookParams;
    protected var _session :FacebookSessionUtilMod;

    protected var _timerManager :TimerManager = new TimerManager();
    protected var _waitingForLogin :Boolean = false;

    protected static var _autoLoadFriends :Boolean = false;
//    protected static var _ctrl :AVRGameControl;
    protected static var _facebookConnection :FacebookConnection;

    protected static const log :Log = Log.getLog(FacebookConnection);
    protected static const REATTEMPT_LOGIN_INTERVAL_MS :Number = 10000;

    protected static const REFRESH_SESSION_INTERVAL_MS :Number = 2000;

    protected static const UUID_CHARACTER_SPACE :String = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

    public static function get friendIds () :Array
    {
        return FriendsModel.friendsIDArray;
    }

    public static function get friends () :Array
    {
        return friendIds.map(Util.adapt(getFriend));
    }

    public static function get instance () :FacebookConnection
    {
        if (_facebookConnection == null) {
            _facebookConnection = new FacebookConnection();
        }
        return _facebookConnection;
    }

    public static function get loggedInUserID () :String
    {
        return instance.facebook.uid;
    }
}
}

import flash.utils.Timer;

class ManagedTimerImpl
{
    public var mgr :TimerManager;
    public var timer :Timer;
    public var timerCallback :Function;
    public var completeCallback :Function;
    public var slot :int;

    public function cancel () :void
    {
        mgr.cancelTimer(this);
    }

    public function reset () :void
    {
        timer.reset();
    }

    public function start () :void
    {
        timer.start();
    }

    public function stop () :void
    {
        timer.stop();
    }

    public function get currentCount () :int
    {
        return timer.currentCount;
    }

    public function get delay () :Number
    {
        return timer.delay;
    }

    public function set delay (val :Number) :void
    {
        timer.delay = val;
    }

    public function get repeatCount () :int
    {
        return timer.repeatCount;
    }

    /*public function set repeatCount (val :int) :void
    {
        timer.repeatCount = val;
    }*/

    public function get running () :Boolean
    {
        return timer.running;
    }
}

import com.threerings.util.ArrayUtil;

import flash.events.TimerEvent;
import flash.utils.Timer;
import com.facebook.data.users.FacebookUser;

/**
 * A class for managing a group of timers.
 */
class TimerManager
{
    /**
     * Constructs a new TimerManager.
     *
     * @param parent (optional) if not null, this TimerManager will become a child of
     * the specified parent TimerManager. If the parent is shutdown, or its cancelAllTimers()
     * function is called, this TimerManager will be similarly affected.
     */
    public function TimerManager (parent :TimerManager = null)
    {
        if (parent != null) {
            _parent = parent;
            parent._children.push(this);
        }
    }

    /**
     * Cancels all running timers, and disconnects the TimerManager from its parent, if it has one.
     * All child TimerManagers will be shutdown as well.
     *
     * It's an error to call any function on TimerManager after shutdown() has been called.
     */
    public function shutdown () :void
    {
        // detach from our parent, if we have one
        if (_parent != null) {
            ArrayUtil.removeFirst(_parent._children, this);
        }

        // shutdown our children
        for each (var child :TimerManager in _children) {
            child._parent = null;
            child.shutdown();
        }

        cancelAllTimers();

        // null out internal state so that future calls to this TimerManager will
        // immediately NPE
        _parent = null;
        _children = null;
        _timers = null;
        _freeSlots = null;
    }

    /**
     * Creates and runs a timer that will run once, and clean up after itself.
     */
    public function runOnce (delay :Number, callback :Function) :void
    {
        var timer :ManagedTimerImpl = createTimer(delay, 1,
            function (e :TimerEvent) :void {
                timer.cancel();
                callback(e);
            });

        timer.start();
    }

    /**
     * Creates and runs a timer that will run forever, or until canceled.
     */
    public function runForever (delay :Number, callback :Function) :ManagedTimerImpl
    {
        var timer :ManagedTimerImpl = createTimer(delay, 0, callback);
        timer.start();
        return timer;
    }

    /**
     * Creates, but doesn't run, a new ManagedTimer.
     */
    public function createTimer (delay :Number, repeatCount :int, timerCallback :Function = null,
        completeCallback :Function = null) :ManagedTimerImpl
    {
        var managedTimer :ManagedTimerImpl = new ManagedTimerImpl();
        managedTimer.mgr = this;
        managedTimer.timer = new Timer(delay, repeatCount);

        if (timerCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER, timerCallback);
            managedTimer.timerCallback = timerCallback;
        }

        if (completeCallback != null) {
            managedTimer.timer.addEventListener(TimerEvent.TIMER_COMPLETE, completeCallback);
            managedTimer.completeCallback = completeCallback;
        }

        if (_freeSlots.length > 0) {
            var slot :int = int(_freeSlots.pop());
            _timers[slot] = managedTimer;
            managedTimer.slot = slot;

        } else {
            _timers.push(ManagedTimerImpl);
            managedTimer.slot = _timers.length - 1;
        }

        return managedTimer;
    }

    /**
     * Stops all timers being managed by this TimerManager.
     * All child TimerManagers will have their timers stopped as well.
     */
    public function cancelAllTimers () :void
    {
        for each (var timer :ManagedTimerImpl in _timers) {
            // we can have holes in the _timers array
            if (timer != null) {
                stopTimer(timer);
            }
        }

        _timers = [];
        _freeSlots = [];

        for each (var child :TimerManager in _children) {
            child.cancelAllTimers();
        }
    }

    /**
     * Cancels a single running ManagedTimer. The timer must have been created by this
     * TimerManager.
     */
    public function cancelTimer (timer :ManagedTimerImpl) :void
    {
        var managedTimer :ManagedTimerImpl = ManagedTimerImpl(timer);
        var slot :int = managedTimer.slot;
        stopTimer(managedTimer);
        _timers[slot] = null;
        _freeSlots.push(slot);
    }

    protected function stopTimer (managedTimer :ManagedTimerImpl) :void
    {
        if (managedTimer.mgr != this) {
            throw new Error("timer is not managed by this TimerManager");
        }

        if (managedTimer.timerCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER, managedTimer.timerCallback);
        }

        if (managedTimer.completeCallback != null) {
            managedTimer.timer.removeEventListener(TimerEvent.TIMER_COMPLETE,
                managedTimer.completeCallback);
        }

        managedTimer.timer.stop();
        managedTimer.timer = null;
        managedTimer.mgr = null;
    }

    public function get localUser () :FacebookUser
    {
        return _localUser;
    }

    public function loadLocalUser (onSuccess :Function = null, onFailure :Function = null) :void
    {
        // localUserId is not set until FacebookMgr is connected, so delay this call until
        // that's the case
        var self :FacebookConnection = this;
        whenConnected(function () :void {
            var caller :FacebookCaller = new FacebookCaller(self,
                new GetInfo([ self.localUserId ], LOCAL_USER_INFO_FIELDS));

            caller.load(
                function () :void {
                    var data :GetInfoData = GetInfoData(caller.data);
                    _localUser = FacebookUser(data.userCollection.getItemAt(0));
                    dispatchEvent(new FacebookDataEvent(FacebookDataEvent.LOCAL_USER_DATA_ARRIVED));
                    if (onSuccess != null) {
                        onSuccess();
                    }
                },
                onFailure);
        });
    }

    protected var _localUser :FacebookUser;
    protected var _timers :Array = [];
    protected var _freeSlots :Array = [];

    protected var _parent :TimerManager;
    protected var _children :Array = [];
}


