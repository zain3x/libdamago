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
// $Id: FunctionTask.as 17 2009-10-05 19:32:01Z tconkling $

package com.plabs.components.tasks {
    import com.pblabs.engine.entity.IEntity;


public class FunctionTask
    implements IEntityTask
{
    public function FunctionTask (fn :Function)
    {
        if (null == fn) {
            throw new ArgumentError("fn must be non-null");
        }

        _fn = fn;
    }

    public function update (dt :Number, obj :IEntity) :Boolean
    {
        _fn();
        return true;
    }

    public function clone () :IEntityTask
    {
        return new FunctionTask(_fn);
    }

    protected var _fn :Function;
}

}
