package com.threerings.util {
import com.threerings.downtown.data.SceneNode;

public class TreeMap
{
    public function TreeMap ()
    {
        _parents = Maps.newMapOf(Hashable);
        _children = Maps.newMapOf(Hashable);
        _vertices = Maps.newMapOf(int);
    }

    public function get root () :Hashable
    {
        return _root;
    }

    public function get vertices () :Array
    {
        return _parents.keys();
    }

    public function replaceVertex (vert :Hashable) :void
    {
        Preconditions.checkArgument(contains(vert), "Does not contain " + vert);
        Preconditions.checkNotNull(vert, "Null replacement");

        var parent :Object = getParent(vert);
        var children :Object = getChildren(vert);
        _parents.put(vert, parent);
        _children.put(vert, children);
        _vertices.put(vert.hashCode(), vert);
    }

    public function getVertex (hash :int) :Hashable
    {
        return _vertices.get(hash) as Hashable;
    }

    public function addVertex (vert :Hashable, parentHash :int) :void
    {
        Preconditions.checkNotNull(vert, "Vertex is null");
        Preconditions.checkArgument(containsId(parentHash) || _root == null,
            "Parent is null, and root is already defined");

        var parent :Hashable = getVertex(parentHash);
        _parents.put(vert, parent);
        _children.put(vert, []);
        _vertices.put(vert.hashCode(), vert);

        if (parent == null) {
            _root = vert;
        } else {
            var parentChildren :Array = _children.get(parent) as Array;
            parentChildren.push(vert);
        }
//		trace("\n    After adding ");
//		trace("\n    parentChildren=", parentChildren);
//		trace("\n    rootchildren=\n      ", getChildren(root).join("\n      "));
//
//		trace("\n    After adding ", vert, "\n    the tree is\n", this);

    }

    public function clear () :void
    {
        _root = null;
        _parents.clear();
        _children.clear();
        _vertices.clear();
    }

    public function contains (vert :Hashable) :Boolean
    {
        return _vertices.containsKey(vert.hashCode());
    }

    public function containsId (hashcode :int) :Boolean
    {
        return _vertices.get(hashcode) != null;
    }

    public function forEach (callback :Function) :void
    {
        forEachChild(root, callback);
    }

    public function forEachChild (start :Hashable, callback :Function, includeStart :Boolean = true) :void
    {
        if (includeStart) {
            callback(start);
        }
        for each (var child :Hashable in (_children.get(start) as Array)) {
            forEachChild(child, callback, true);
        }
    }

    public function forEachParent (start :Hashable, callback :Function, includeStart :Boolean = true) :void
    {
        if (includeStart) {
            callback(start);
        }
        if (_parents.get(start) != null) {
            forEachParent(_parents.get(start), callback, true);
        }
    }

    public function findFirstIf (predicate :Function) :Hashable
    {
        var result :Hashable = null;
        _parents.forEach(function (vert :Hashable, ..._) :void {
            if (result == null && predicate(vert)) {
                result = vert;
            }
        });
        return result;
    }

    public function findFirstDownTree (startNode :Hashable, predicate :Function) :Hashable
    {
        if (predicate(startNode)) {
            return startNode;
        }

        for each (var child :Hashable in _children.get(startNode)) {
            var result :Hashable = findFirstDownTree(child, predicate);
            if (result != null) {
                return result;
            }
        }
        return null;
    }

    public function getChildren (vert :Hashable) :Array
    {
        Preconditions.checkArgument(contains(vert), "Does not contain " + vert);
        return (_children.get(vert) as Array).concat();//Clone for safety
    }

    public function getParent (vert :Hashable) :Hashable
    {
        Preconditions.checkArgument(contains(vert), "Does not contain " + vert);
        return _parents.get(vert) as Hashable;
    }

    public function removeVertex (vert :Hashable) :Object
    {
        if (!contains(vert)) {
            return null;
        }

        if (vert == _root) {
            clear();
            return vert;
        }

        var parent :Hashable = getParent(vert);
        var parentChildren :Array = _children.get(parent) as Array;
        var children :Array = _children.get(vert) as Array;

        for each (var child :Hashable in children) {
            removeVertex(child);
        }

        ArrayUtil.removeAll(parentChildren, vert);
        _parents.remove(vert);
        _children.remove(vert);
        _vertices.remove(vert.hashCode());
        return vert;
    }

    public function size () :int
    {
        return _parents.size();
    }

    public function toString () :String
    {
        return treeString(root);
    }

    public function treeString (vert :Hashable, sep :String = "  ") :String
    {
        var s :String = "\n" + sep + vert;
        sep += "  ";
        for each (var child :Hashable in getChildren(vert)) {
            s += treeString(child, sep);
        }
        return s;
    }

    protected var _vertices :Map;
    protected var _children :Map;//<Object, Array>
    protected var _parents :Map;//<Object, Object>
    protected var _root :Hashable;
}
}