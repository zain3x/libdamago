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
// $Id: PlayFramesTask.as 17 2009-10-05 19:32:01Z tconkling $

package com.plabs.components.tasks {

import com.pblabs.engine.entity.IEntity;
import com.threerings.flashbang.*;
import com.threerings.flashbang.components.*;
import com.threerings.flashbang.objects.*;

import flash.display.MovieClip;

import mx.effects.easing.Linear;

public class PlayFramesTask
    implements IEntityTask
{
    public function PlayFramesTask (startFrame :int, endFrame :int, totalTime :Number,
        movie :MovieClip)
    {
        _startFrame = startFrame;
        _endFrame = endFrame;
        _totalTime = totalTime;
        _movie = movie;

        if (null == _movie) {
            throw new Error("Movie cannot be null");
        }
    }

    public function update (dt :Number, obj :IEntity) :Boolean
    {
        var movieClip :MovieClip = _movie;

        _elapsedTime = Math.min(_elapsedTime + dt, _totalTime);
        var curFrame :int = Math.floor(mx.effects.easing.Linear.easeNone(
            _elapsedTime,
            _startFrame, _endFrame - _startFrame,
            _totalTime));
        _movie.gotoAndStop(curFrame);

        return _elapsedTime >= _totalTime;
    }

    public function clone () :IEntityTask
    {
        return new PlayFramesTask(_startFrame, _endFrame, _totalTime, _movie);
    }


    protected var _startFrame :int;
    protected var _endFrame :int;
    protected var _totalTime :Number;
    protected var _movie :MovieClip;

    protected var _elapsedTime :Number = 0;
}

}
