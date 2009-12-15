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
// $Id: ColorMatrixBlendTask.as 25 2009-10-27 20:19:09Z tconkling $

package com.plabs.components.tasks {

import com.pblabs.engine.entity.IEntity;
import com.threerings.display.ColorMatrix;
import com.threerings.display.FilterUtil;

import flash.display.DisplayObject;
import flash.filters.ColorMatrixFilter;

import mx.effects.easing.*;

public class ColorMatrixBlendTask
    implements IEntityTask
{
    public static function colorize (fromColor :uint, toColor :uint,
        time :Number, disp :DisplayObject, easingFn :Function = null,
        preserveFilters :Boolean = false) :ColorMatrixBlendTask
    {
        return new ColorMatrixBlendTask(
            new ColorMatrix().colorize(fromColor, 1),
            new ColorMatrix().colorize(toColor, 1),
            time,
            disp,
            easingFn,
            preserveFilters);
    }

    public function ColorMatrixBlendTask (cmFrom :ColorMatrix,
        cmTo :ColorMatrix, time :Number, disp :DisplayObject = null,
        easingFn :Function = null,
        preserveFilters :Boolean = false)
    {
        _disp = disp;
        _from = cmFrom;
        _to = cmTo;
        _totalTime = time;
        _easingFn = (easingFn != null ? easingFn : mx.effects.easing.Linear.easeNone);
        _preserveFilters = preserveFilters;
    }

    public function update (dt :Number, obj :IEntity) :Boolean
    {
        _elapsedTime += dt;

        var amount :Number = _easingFn(Math.min(_elapsedTime, _totalTime), 0, 1, _totalTime);
        var filter :ColorMatrixFilter = _from.clone().blend(_to, amount).createFilter();

        // If _preserveFilters is set, we'll preserve any filters already on the DisplayObject
        // when adding the new filter. This can be an expensive operation, so it's false by default.
        if (_preserveFilters) {
            if (_oldFilter != null) {
                FilterUtil.removeFilter(_disp, _oldFilter);
            }
            FilterUtil.addFilter(_disp, filter);
            _oldFilter = filter;

        } else {
            _disp.filters = [ filter ];
        }

        return (_elapsedTime >= _totalTime);
    }

    public function clone () :IEntityTask
    {
        return new ColorMatrixBlendTask(_from, _to, _totalTime, _disp,
            _easingFn, _preserveFilters);
    }

    protected var _disp :DisplayObject;
    protected var _from :ColorMatrix;
    protected var _to :ColorMatrix;
    protected var _totalTime :Number;
    protected var _easingFn :Function;
    protected var _preserveFilters :Boolean;

    protected var _oldFilter :ColorMatrixFilter;

    protected var _elapsedTime :Number = 0;
}

}
