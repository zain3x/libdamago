// Flashbang - a framework for creating Flash games
// http://code.google.com/p/flashbang/
//
// This library is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This library is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this library.  If not, see <http://www.gnu.org/licenses/>.
//
// Copyright 2008 Three Rings Design
//
// $Id: LocationTask.as 25 2009-10-27 20:19:09Z tconkling $

package com.plabs.components.tasks {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.LocationComponent;

import flash.display.DisplayObject;

import mx.effects.easing.*;

public class LocationTask extends InterpolatingTask
    implements EntityTask
{
    public static function CreateLinear (xRef :PropertyReference, yRef :PropertyReference, x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(xRef, yRef, x, y, time, mx.effects.easing.Linear.easeNone,);
    }

    // public static function CreateSmooth (x :Number, y :Number, time :Number,
    //     disp :DisplayObject = null) :LocationTask
    // {
    //     return new LocationTask(x, y, time, mx.effects.easing.Cubic.easeInOut, disp);
    // }

    // public static function CreateEaseIn (x :Number, y :Number, time :Number,
    //     disp :DisplayObject = null) :LocationTask
    // {
    //     return new LocationTask(x, y, time, mx.effects.easing.Cubic.easeIn, disp);
    // }

    // public static function CreateEaseOut (x :Number, y :Number, time :Number,
    //     disp :DisplayObject = null) :LocationTask
    // {
    //     return new LocationTask(x, y, time, mx.effects.easing.Cubic.easeOut, disp);
    // }

    public function LocationTask (xRef :PropertyReference, yRef :PropertyReference, x :Number, y
    :Number, time :Number = 0, easingFn :Function = null)
    {
        super(time, easingFn);
        _toX = x;
        _toY = y;
        _xRef = xRef;
        _yRef = yRef;
    }

    override public function update (dt :Number, obj :IEntity) :Boolean
    {
        if (0 == _elapsedTime) {
            _fromX = obj.getProperty(_xRef) as Number;
            _fromY = obj.getProperty(_yRef) as Number;
        }

        _elapsedTime += dt;

        obj.setProperty(_xRef, interpolate(_fromX, _toX, _elapsedTime, _totalTime, _easingFn));
        obj.setProperty(_yRef, interpolate(_fromY, _toY, _elapsedTime, _totalTime, _easingFn));

        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :ObjectTask
    {
        return new LocationTask(_xRef, _yRef, _toX, _toY, _totalTime, _easingFn);
    }

    protected var _toX :Number;
    protected var _toY :Number;
    protected var _fromX :Number;
    protected var _fromY :Number;
    protected var _xRef :PropertyReference;
    protected var _yRef :PropertyReference;
}

}
