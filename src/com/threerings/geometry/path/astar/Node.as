package com.threerings.geometry.path.astar {
import com.threerings.geom.Vector2;

/**
 * A tile that will work with the A* search needs to implment INode. It can extend this class for convenience, which already implements INode.
 */
public class Node implements INode
{

    public function Node ()
    {
    }

    public function getCol () :int
    {
        return col;
    }

    public function getHeuristic () :Number
    {
        return heuristic;
    }

    public function getNeighbors () :Array
    {
        return neighbors;
    }

    public function getNodeCenter () :Vector2
    {
        throw new Exception("Not implemented");
    }

    public function getNodeId () :int
    {
        return nodeId;
    }

    public function getNodeType () :String
    {
        return nodeType;
    }

    public function getRow () :int
    {
        return row;
    }

    public function setCol (num :int) :void
    {
        col = num;
    }

    public function setHeuristic (h :Number) :void
    {
        heuristic = h;
    }

    public function setNeighbors (arr :Array) :void
    {
        neighbors = arr;
    }

    public function setNodeId (nodeId :int) :void
    {
        this.nodeId = nodeId;
    }

    public function setNodeType (type :String) :void
    {
        nodeType = type;
    }

    public function setRow (num :int) :void
    {
        row = num;
    }
    private var col :int;
    private var heuristic :Number;
    private var neighbors :Array;
    private var nodeId :int;
    private var nodeType :String;
    private var row :int;
}

}
