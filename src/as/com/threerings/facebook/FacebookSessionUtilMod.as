/*
  Copyright (c) 2009, Adobe Systems Incorporated
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

  * Redistributions of source code must retain the above copyright notice,
    this list of conditions and the following disclaimer.

  * Redistributions in binary form must reproduce the above copyright
    notice, this list of conditions and the following disclaimer in the
    documentation and/or other materials provided with the distribution.

  * Neither the name of Adobe Systems Incorporated nor the names of its
    contributors may be used to endorse or promote products derived from
    this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
  IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO,
  THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
  PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
  CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
  PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
package com.threerings.facebook
{

import flash.display.LoaderInfo;
import flash.events.EventDispatcher;
import flash.net.SharedObject;
import flash.system.Capabilities;

import com.facebook.Facebook;
import com.facebook.events.FacebookEvent;
import com.facebook.facebook_internal;
import com.facebook.session.DesktopSession;
import com.facebook.session.IFacebookSession;
import com.facebook.session.JSSession;
import com.facebook.session.WebSession;

import com.threerings.util.Log;

/**
 * Modified from the original FacebookSessionUtil to handle explicit session keys
 * (retrieved from the Whirled AVRG API).
 *
 * The FacebookSessionUtil class provides a convenient way to create
 * or continue a Facebook session. This class handles many of the tasks that
 * you would otherwise have to handle manually. The FacebookSessionUtil class
 * constructor:
 * <ul>
 *   <li>Checks whether an existing session is stored as a SharedObject
 *       on the user's computer and uses that session key if it exists.</li>
 *   <li>Checks whether the Facebook server provided a new session key
 *       and gives that session key precedence over the SharedObject session key.</li>
 *   <li>Checks whether the Facebook server sends a session secret to
 *       use in place of your application secret and uses the session
 *       secret if it exists.</li>
 *   <li>Attempts to determine what type of session you are using, either a
 *       DesktopSession, a WebSession, or a JSSession (JavaScript Bridge Session).
 *       If it cannot determine the type of session,
 *       it uses a DesktopSession.</li>
 *   <li>Creates a session of the type determined in the previous step and
 *       stores the session in the public property named <code>activeSession</code>.</li>
 *   <li>Creates an instance of the Facebook class and stores the instance
 *       in a public property named <code>facebook</code>.</li>
 *   <li>Starts a session of the appropriate type.</li>
 * </ul>
 *
 * @see com.facebook.session
 * @see http://wiki.developers.facebook.com/index.php/Session_Secret
 */
public class FacebookSessionUtilMod extends EventDispatcher
{

    /**
     * The instance of the Facebook class created by the constructor.
     */
    public var facebook:Facebook;
    protected var api_key:String;
    protected var _activeSession:IFacebookSession;

    /**
     * The constructor creates a new session of the appropriate type.
     * See the FacebookSessionUtil class description for detailed information
     * about the constructor.
     *
     * @param api_key Your application's API key.
     * @param secret Your application's secret key. If this parameter is passed
     * a value of <code>null</code>, the constructor looks for a special
     * session secret stored in the <code>fb_sig_ss</code> property of the
     * <code>loaderInfo</code> object. For web sessions, even if you pass a
     * non-null value for this parameter, the constructor will always look
     * for a session secret and use that instead of the value that you pass
     * for this parameter.
     * @param loaderInfo An object of type LoaderInfo that provides information
     * about the loaded SWF file.
     */

    public function FacebookSessionUtilMod (api_key:String, secret :String, sessionKey :String,
        uid :String, loaderInfo :LoaderInfo = null) {

        this.api_key = api_key;
        var flashVars:Object = loaderInfo != null?loaderInfo.parameters:{};

        if ((loaderInfo != null && loaderInfo.url != null && loaderInfo.url.slice(0, 5) == "file:") || Capabilities.playerType == "Desktop") {
            //desktop application
            log.debug("Desktop session");
            _activeSession = new DesktopSession(api_key, secret);
        } else if (secret != null && api_key != null && sessionKey != null) {
            //Web application
            log.debug("Web session");
            _activeSession = new WebSession(api_key, secret, sessionKey);
            if (uid != null) {
                (_activeSession as WebSession).facebook_internal::_uid = uid;
            }
        } else if(flashVars.as_app_name) {
            //jsBridge application
            log.debug("WjsBridgeeb session");
            _activeSession = new JSSession(api_key, flashVars.as_app_name);
        } else {
            //could not determine facebook connection type, so just use DesktopSession
            log.debug("Desktop session, because none of the others fit");
            _activeSession = new DesktopSession(api_key, secret);
        }
        _activeSession.session_key = sessionKey;

        _activeSession.addEventListener(FacebookEvent.VERIFYING_SESSION, onVerifyingSession);

        //Create our facebook instance
        facebook = new Facebook();
        facebook.addEventListener(FacebookEvent.WAITING_FOR_LOGIN, handleWaitingForLogin);
        facebook.addEventListener(FacebookEvent.CONNECT, onFacebookReady);
        facebook.startSession(_activeSession);
    }
    /**
     * Purges user login data.
     * Cleans up sharedObject data.
     */
    public function logout () :void
    {
        getStoredSession().clear();
        getStoredSession().flush();
        facebook.logout();
    }

    public function onVerifyingSession (event:FacebookEvent) :void
    {
        dispatchEvent(event);
    }

    /**
     * The active session created by the constructor.
     */
    public function get activeSession () :IFacebookSession
    {
        return _activeSession;
    }

    public function login (offline_access:Boolean = true) :void
    {
        log.debug("login");
        facebook.login(offline_access);
    }

    protected function handleWaitingForLogin (event:FacebookEvent) :void
    {
        log.debug("handleWaitingForLogin");
        dispatchEvent(event);
    }

    /**
     * Call first to check an established login.
     */
    public function verifySession () :void
    {
        log.debug("verifySession");
        _activeSession.verifySession();
    }

    /**
     * if there is no prior login session, validate create a new session
     */

    public function validateLogin () :void
    {
        log.debug("validateLogin");
        facebook.refreshSession();
    }

    protected function onVerifyLogin (event:FacebookEvent) :void
    {
        log.debug("onVerifyLogin");
        _activeSession.removeEventListener(FacebookEvent.CONNECT, onVerifyLogin);
        if (event.success) {
            onFacebookReady(null);
            dispatchEvent(new FacebookEvent(FacebookEvent.CONNECT, false, false, true));
        } else {
            dispatchEvent(new FacebookEvent(FacebookEvent.CONNECT, false, false, false));
        }
    }

    /**
     * get the stored session for the set api
     */
    protected function getStoredSession ():SharedObject {
        return SharedObject.getLocal(api_key+"_stored_session");
    }

    protected function onWaitingForLogin (event:FacebookEvent) :void
    {
        log.debug("onWaitingForLogin");
        dispatchEvent(event);
    }

    /**
     * Called when the facebook connection is ready.
     */
    protected function onFacebookReady (event:FacebookEvent) :void
    {
        log.debug("onFacebookReady");
        if (facebook.session_key) {
            var storedSession:SharedObject = getStoredSession();
            storedSession.data.session_key = facebook.session_key;
            storedSession.data.stored_secret = facebook.secret;
            storedSession.flush(3000);
        }

        if (event) {
            dispatchEvent(event);
        }
    }

    protected static const log :Log = Log.getLog(FacebookSessionUtilMod);
}
}
