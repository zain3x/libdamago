//
// $Id: Util.as 4637 2009-08-19 21:06:13Z tim $

package libdamago.util{

import com.threerings.util.Map;
import com.threerings.util.StringBuilder;

import flash.utils.*;

public class Util
{
    public static function getTimestamp () :Number
    {
        return new Date().time;
    }

    public static function formatTimerString (seconds :int) :String
    {
        var mins :int = seconds / 60;
        seconds %= 60;

        return String(mins) + ":" + (seconds >= 10 ? String(seconds) : "0" + String(seconds));
    }

    /**
     * If n >= 1, just use the integer for the string.  Otherwise, show to 2 decimal places.
     */
    public static function formatNumberForFeedback (n :Number) :String
    {
        if (n >= 1) {
            return "" + int(Math.floor(n));

        } else {
            var nString :String = "" + n;
            return nString.substring(0, Math.min(nString.indexOf(".") + 3, nString.length));
        }
    }

    public static function getStringHash (val :String) :int
    {
        // examine at most 32 characters of the val
        var hash :int;
        var inc :int = int(Math.max(1, Math.ceil(val.length / 32)));
        for (var ii :int = 0; ii < val.length; ii += inc) {
            // hash(i) = (hash(i-1) * 33) ^ str[i]
            hash = ((hash << 5) + hash) ^ int(val.charCodeAt(ii));
        }

        return hash;
    }

    public static function obfuscateInt (value :int) :String
    {
        return Math.round(Math.random()*1000) + ";" + value;
    }

    public static function deobfuscateInt (value :String) :int
    {
        if (value == null) {
            return 0;
        }
        return int(value.split(";")[1]);
    }

    public static function colorizeText (text :String, colorString :String) :String
    {
        return styleText(text, colorString);
    }

    public static function enlargeText (text :String, sizeOffset :int) :String
    {
        return styleText(text, null, sizeOffset);
    }

    public static function styleText (text :String, colorString :String = null,
        sizeOffset :int = 0, absoluteSize :int = 0) :String
    {
        if (text.length == 0) {
            return text;
        } else {
            var out :String = "<font";
            if (colorString != null) {
                out += ' color="' + colorString + '"';
            }
            if (sizeOffset != 0 || absoluteSize != 0) {
                var size :int = (sizeOffset != 0 ? sizeOffset : absoluteSize);
                var relativeSize :Boolean = (sizeOffset != 0);
                out += ' size="';
                if (relativeSize) {
                    out += (size > 0 ? "+" : "-");
                }
                out += size + '"';
            }
            out += ">" + text + "</font>";
            return out;
        }
    }
}
}
