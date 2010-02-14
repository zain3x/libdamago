package cheat {
import flash.utils.Dictionary;

/**
 * Detects in-memory cheats.  Disclaimer: this is not fool-proof!  Encrypt/Obfuscate your game
 * variables as well!
 *
 * Three copies of values are stored (two are XORed for obfuscation).
 * If the three copies are not identical on the update loop, then in-memory
 * hacking is almost certain occuring, and the callback is invoked.
 */
public class CheatDetector
{

    public static const PLAYER_CHEATED :String = "Player Cheated";

    /**
     * @cheatDetectedCallback : Called cheatDetectedCallback(key, trueValue, hacked value)
     * when in-memory hacking occurs.
     *
     */
    public function CheatDetector (cheatDetectedCallback :Function)
    {
        _cheatCallBack = cheatDetectedCallback;
    }

    public function get (key :String) :int
    {
        var mi :MultiInt = _values[key] as MultiInt;

        if (mi != null) {
            return mi.value1;
        }
        return 0;
    }

    public function repair (key :String) :void
    {
        var mi :MultiInt = _values[key] as MultiInt;
        if (mi != null) {
            mi.repair();
        }
    }

    public function set (key :String, value :int) :void
    {
        var mi :MultiInt = _values[key] as MultiInt;

        if (mi == null) {
            _values[key] = new MultiInt(value);

        } else {
            mi.set(value);
        }
    }

    public function toString () :String
    {
        var s :String = "\n";
        for (var key :String in _values) {
            s += "\n  key=" + key;
            s += "\n  value=" + _values[key];

        }
        return s;
    }

    public function update (dt :Number) :void
    {
        for (var key :String in _values) {
            var mi :MultiInt = _values[key] as MultiInt;
            if (mi != null) {
                if (mi.isHacking()) {
                    _cheatCallBack(key, mi.trueValue(), mi.hackedValue());
                        //                    mi.repair();
                }
            }
        }
    }

    protected var _cheatCallBack :Function;
    protected var _values :Dictionary = new Dictionary();
}
}

class MultiInt
{
    public function MultiInt (value :int)
    {
        set(value);
    }

    public function get value1 () :int
    {
        return _values[0];
    }

    public function set value1 (value :int) :void
    {
        _values[0] = value;
    }

    public function get value2 () :int
    {
        return _values[1];
    }

    public function set value2 (value :int) :void
    {
        _values[1] = value;
    }

    public function get value3 () :int
    {
        return _values[2];
    }

    public function set value3 (value :int) :void
    {
        _values[2] = value;
    }

    //Unfinished.  Currently we assume the first (unobfuscated) value is hacked
    public function hackedValue () :int
    {
        return value1;
    }

    public function isHacking () :Boolean
    {
        return !(value1 == (value2 ^ value2XOR) && value1 == (value3 ^ value3XOR));
    }

    public function repair () :void
    {
        if (value1 == (value2 ^ value2XOR)) {
            value3 = int(value1) ^ value3XOR;
        } else if ((value2 ^ value2XOR) == (value3 ^ value3XOR)) {
            value1 = int(value2) ^ value2XOR;
        } else if (value1 == (value3 ^ value3XOR)) {
            value2 = int(value1) ^ value2XOR;
        } else {
            trace("More than one variable changed at once!");
            value1 = 0;
            value2 = 0;
            value3 = 0;
        }
    }

    public function set (value :int) :void
    {
        value1 = int(value);
        value2 = int(value) ^ value2XOR;
        value3 = int(value) ^ value3XOR;
    }

    public function toString () :String
    {
        return value1 + " " + (value2 ^ value2XOR) + " " + (value3 ^ value3XOR);
    }

    /**
     * If the 2nd and third value are equal, return the second value.
     * Otherwise return the 1st.  If the 1st and 2nd value are both altered,
     * this detection system fails.
     */
    public function trueValue () :int
    {
        if ((value2 ^ value2XOR) == (value3 ^ value3XOR)) {
            return value2 ^ value2XOR;
        } else {
            return value1;
        }
    }

    protected var _value1 :int;
    protected var _value2 :int;
    protected var _value3 :int;

    protected var _values :Array = [ 0, 0, 0 ];

    //    protected var value1 :int;
    //    protected var value2 :int;
    //    protected var value3 :int;

    //These can be any value.
    protected static const value2XOR :int = 98765;
    protected static const value3XOR :int = 987650;
}
