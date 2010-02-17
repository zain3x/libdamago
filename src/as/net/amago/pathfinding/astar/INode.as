
package net.amago.pathfinding.astar {
import com.threerings.geom.Vector2;

/**
 * This class must be implemented by a tile that is used in a search by the Astar class. They just have to be implmented as getters and setters -- no logic.
 */
public interface INode
{

    /**
     * Sets the heuristic property.
     * @param    The value.
     */
    function setHeuristic (h :Number) :void;
    /**
     * Gets the heuristic property.
     * @return The value of the heuristic property.
     */
    function getHeuristic () :Number;

    /**
     * Sets the array of heighbors around a node.
     * @param    Array of heighboring INodes.
     */
    function setNeighbors (arr :Array) :void;
    /**
     * Gets a node's id.
     * @return The node's id.
     */
    function getNodeId () :int;
    /**
     * Gets the node's neighbors.
     * @return The neighbors of the node.
     */
    function getNeighbors () :Array;
    /**
     * Gets the node type.
     * @return  The node type.
     */
    function getNodeType () :String;
    /**
     * Sets the node type.
     * @param    The node type.
     */
    function setNodeType (type :String) :void;

    /**
     * Gets node center.
     * @return  The node type.
     */
    function getNodeCenter () :Vector2;
}
}
