package com.threerings.flashbang.pushbutton.tasks {
import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.LocationComponent;
import com.threerings.flashbang.tasks.InterpolatingTask;

import mx.effects.easing.*;

/**
 * The regular location task doesn't take a LocationComponent in the constructor.
 */
public class LocationTaskComponent extends InterpolatingTask
    implements ObjectTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number,
        comp :LocationComponent = null) :LocationTaskComponent
    {
        return new LocationTaskComponent(x, y, time, mx.effects.easing.Linear.easeNone, comp);
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number,
        comp :LocationComponent = null) :LocationTaskComponent
    {
        return new LocationTaskComponent(x, y, time, mx.effects.easing.Cubic.easeInOut, comp);
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number,
        comp :LocationComponent = null) :LocationTaskComponent
    {
        return new LocationTaskComponent(x, y, time, mx.effects.easing.Cubic.easeIn, comp);
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number,
        comp :LocationComponent = null) :LocationTaskComponent
    {
        return new LocationTaskComponent(x, y, time, mx.effects.easing.Cubic.easeOut, comp);
    }

    public function LocationTaskComponent (x :Number, y :Number, time :Number = 0,
        easingFn :Function = null, comp :LocationComponent = null)
    {
        super(time, easingFn);
        _toX = x;
        _toY = y;
        _locationComponent = comp;
    }

    override public function update (dt :Number, obj :GameObject) :Boolean
    {
        var lc :LocationComponent =
            (null != _locationComponent ? _locationComponent : obj as LocationComponent);

        if (null == lc) {
            throw new Error("obj does not implement LocationComponent");
        }

        if (0 == _elapsedTime) {
            _fromX = lc.x;
            _fromY = lc.y;
        }

        _elapsedTime += dt;

        lc.x = interpolate(_fromX, _toX, _elapsedTime, _totalTime, _easingFn);
        lc.y = interpolate(_fromY, _toY, _elapsedTime, _totalTime, _easingFn);

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTaskComponent(_toX, _toY, _totalTime, _easingFn, _locationComponent);
    }

    protected var _toX :Number;
    protected var _toY :Number;
    protected var _fromX :Number;
    protected var _fromY :Number;
    protected var _locationComponent :LocationComponent;
}

}
