package com.threerings.pathfinding.navmesh
{
import com.threerings.geom.Vector2;
import com.threerings.util.Hashable;

import com.threerings.geometry.VectorUtil;
import com.threerings.pathfinding.astar.INode;

public class NavMeshNode extends Vector2
    implements INode
{
    protected static var IDCOUNT :int = 0;
    protected var _heuristic :Number;
    public var _id :int;

    protected var _neighborsAll :Array;

    public function get vector () :Vector2
    {
        return this;
    }

    public function hashCode () :int
    {
        return _id;
    }

    public function NavMeshNode (nodeX :Number, nodeY :Number)
    {
        super(nodeX, nodeY);
        _neighborsAll = new Array();
        _heuristic = 0;
        _id = IDCOUNT++;
    }

    public static function fromVector2 (v :Vector2) :NavMeshNode
    {
        return new NavMeshNode(v.x, v.y);
    }




    public function setHeuristic(h:Number):void
    {
        _heuristic = h;
    }

    public function getHeuristic():Number
    {
        return _heuristic;
    }


    public function getNodeId():int
    {
        return _id;
    }

    public function setNeighbors(arr:Array):void
    {
        _neighborsAll = arr;
    }

    public function getNeighbors():Array
    {
        return _neighborsAll;
    }

    public function getNeighborsNeighbours():Array
    {
        return null;
    }

    public function getNodeType():String
    {
        return null;
    }

    public function setNodeType(type:String):void
    {
    }

    public function getNodeCenter():Vector2
    {
        return this;
    }

    override public function toString() :String
    {
//        return "" + _id;
        return toStringLong();
    }

    public function toStringLong() :String
    {
        return "" + _id + ":" + super.toString();// + ", neighbours=" + getNeighbors().length;
    }

    public function distance (v :Vector2) :Number
    {
        return VectorUtil.distance(this, v);
    }

    public function distanceSq (v :Vector2) :Number
    {
        return VectorUtil.distanceSq(this, v);
    }

}
}
