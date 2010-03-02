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
// $Id$
package com.threerings.flashbang.resource {
import com.threerings.util.StringUtil;
public class DiskResourceDesc
{
    public var clazz :Class;
    public var filename :String;
    public var resourceType :String;

    public function DiskResourceDesc (resourceType :String, filename :String, clazz :Class)
    {
        this.resourceType = resourceType;
        this.filename = filename;
        this.clazz = clazz;
    }

    public function get resourceName () :String
    {
        return trimPath(trimExtension(filename));
    }

    protected static function trimExtension (filename :String) :String
    {
        var dotIdx :int = filename.lastIndexOf(".");
        return (dotIdx >= 0 ? filename.substring(0, dotIdx) : filename);
    }

    protected static function trimPath (filename :String) :String
    {
        var slashIdx :int = filename.lastIndexOf("/");
        if (slashIdx < 0) {
            return filename;
        } else if (slashIdx < filename.length - 1) {
            return filename.substr(slashIdx + 1);
        } else {
            return "";
        }
    }
}

}