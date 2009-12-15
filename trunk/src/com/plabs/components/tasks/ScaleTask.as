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
// $Id: ScaleTask.as 25 2009-10-27 20:19:09Z tconkling $

package com.plabs.components.tasks {

import com.pblabs.engine.entity.IEntity;
import com.threerings.flashbang.components.ScaleComponent;

import flash.display.DisplayObject;

import mx.effects.easing.*;

public class ScaleTask extends InterpolatingTask
{
    public static function CreateLinear (x :Number, y :Number, time :Number,
        disp :DisplayObject) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Linear.easeNone, disp);
    }

    public static function CreateSmooth (x :Number, y :Number, time :Number,
        disp :DisplayObject) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeInOut, disp);
    }

    public static function CreateEaseIn (x :Number, y :Number, time :Number,
        disp :DisplayObject) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeIn, disp);
    }

    public static function CreateEaseOut (x :Number, y :Number, time :Number,
        disp :DisplayObject) :ScaleTask
    {
        return new ScaleTask(x, y, time, mx.effects.easing.Cubic.easeOut, disp);
    }

    public function ScaleTask (x :Number, y :Number, time :Number,
        easingFn :Function, disp :DisplayObject)
    {
        super(time, easingFn);
        _toX = x;
        _toY = y;
        _disp = disp;
    }

    override public function update (dt :Number, obj :IEntity) :Boolean
    {
        if (0 == _elapsedTime) {
            _fromX = _disp.scaleX;
            _fromY = _disp.scaleY;
        }

        _elapsedTime += dt;
        _disp.scaleX = interpolate(_fromX, _toX, _elapsedTime, _totalTime, _easingFn);
        _disp.scaleY = interpolate(_fromY, _toY, _elapsedTime, _totalTime, _easingFn);
        return (_elapsedTime >= _totalTime);
    }

    override public function clone () :IEntityTask
    {
        return new ScaleTask(_toX, _toY, _totalTime, _easingFn, _disp);
    }

    protected var _toX :Number;
    protected var _toY :Number;
    protected var _fromX :Number;
    protected var _fromY :Number;
    protected var _disp :DisplayObject;
}

}
