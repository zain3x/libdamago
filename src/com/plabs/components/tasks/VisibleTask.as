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
// $Id: VisibleTask.as 25 2009-10-27 20:19:09Z tconkling $

package com.plabs.components.tasks {

import com.threerings.flashbang.GameObject;
import com.threerings.flashbang.ObjectMessage;
import com.threerings.flashbang.ObjectTask;
import com.threerings.flashbang.components.VisibleComponent;

import flash.display.DisplayObject;

public class VisibleTask
    implements ObjectTask
{
    public function VisibleTask (visible :Boolean, disp :DisplayObject = null)
    {
        _visible = visible;
        _dispOverride = DisplayObjectWrapper.create(disp);
    }

    public function update (dt :Number, obj :GameObject) :Boolean
    {
        var vc :VisibleComponent =
            (!_dispOverride.isNull ? _dispOverride : obj as VisibleComponent);
        if (null == vc) {
            throw new Error("obj does not implement VisibleComponent");
        }

        vc.visible = _visible;
        return true;
    }

    public function clone () :ObjectTask
    {
        return new VisibleTask(_visible, _dispOverride.displayObject);
    }

    public function receiveMessage (msg :ObjectMessage) :Boolean
    {
        return false;
    }

    protected var _visible :Boolean;
    protected var _dispOverride :DisplayObjectWrapper;
}

}
