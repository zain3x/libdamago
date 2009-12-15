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
// $Id: WaitForFrameTask.as 17 2009-10-05 19:32:01Z tconkling $

package com.plabs.components.tasks {

import com.pblabs.engine.entity.IEntity;

import flash.display.MovieClip;

public class WaitForFrameTask implements IEntityTask
{
    public function WaitForFrameTask (frameLabelOrNumber :*, movie :MovieClip)
    {
        if (frameLabelOrNumber is int) {
            _frameNumber = frameLabelOrNumber as int;
        } else if (frameLabelOrNumber is String) {
            _frameLabel = frameLabelOrNumber as String;
        } else {
            throw new Error("frameLabelOrNumber must be a String or an int");
        }

        _movie = movie;
    }

    public function update (dt :Number, obj :IEntity) :Boolean
    {
        var movieClip :MovieClip = _movie;
        return (null != _frameLabel ? movieClip.currentLabel == _frameLabel :
                                      movieClip.currentFrame == _frameNumber);
    }

    public function clone () :IEntityTask
    {
        return new WaitForFrameTask(null != _frameLabel ? _frameLabel : _frameNumber, _movie);
    }


    protected var _frameLabel :String;
    protected var _frameNumber :int;
    protected var _movie :MovieClip;

}

}
