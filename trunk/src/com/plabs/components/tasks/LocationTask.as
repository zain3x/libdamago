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

import com.pblabs.engine.entity.PropertyReference;

import mx.effects.easing.*;

public class LocationTask extends ParallelTask
{
    public static function CreateLinear (xRef :PropertyReference, yRef :PropertyReference,
        x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(xRef, yRef, x, y, time, mx.effects.easing.Linear.easeNone);
    }

    public static function CreateSmooth (xRef :PropertyReference, yRef :PropertyReference,
        x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(xRef, yRef, x, y, time, mx.effects.easing.Cubic.easeInOut);
    }

    public static function CreateEaseIn (xRef :PropertyReference, yRef :PropertyReference,
        x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(xRef, yRef, x, y, time, mx.effects.easing.Cubic.easeIn);
    }

    public static function CreateEaseOut (xRef :PropertyReference, yRef :PropertyReference,
        x :Number, y :Number, time :Number) :LocationTask
    {
        return new LocationTask(xRef, yRef, x, y, time, mx.effects.easing.Cubic.easeOut);
    }

    public function LocationTask (xRef :PropertyReference, yRef :PropertyReference, x :Number, y
    :Number, time :Number = 0, easingFn :Function = null)
    {
        super(new AnimateValueTask(xRef, x, time, easingFn),
            new AnimateValueTask(yRef, y, time, easingFn));
    }

}
}
