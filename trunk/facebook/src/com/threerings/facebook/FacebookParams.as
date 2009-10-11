package com.threerings.facebook
{
import com.threerings.util.StringUtil;

public class FacebookParams
{
    public function FacebookParams (apiKey :String, secretKey :String, sessionKey :String,
        uid :String)
    {
        this.apiKey = apiKey;
        this.secretKey = secretKey;
        this.sessionKey = sessionKey;
        this.uid = uid;
    }

    public function toString () :String
    {
        return StringUtil.simpleToString(this, ["apiKey", "secretKey", "uid", "sessionKey"]);
    }

    public var apiKey :String;
    public var secretKey :String;
    public var sessionKey :String;
    public var uid :String;

}
}
