package net.amago.pathfinding.astar {

/**
 * This interface must be implemented by anything that wants to be searchable by the Astar class.
 */
public interface ISearchable
{
    /**
     * Gets the node for a specific row/column combo.
     * @param    Column that the node is in.
     * @param    Row that the node is in.
     * @return The INode instance.
     */
//    function getNodeUnder (x :Number, y :Number) :INode;
    /**
     * Gets the terrain transition cost between one node type and another.
     * @param    The first node.
     * @param    The second node.
     * @return The transition cost.
     */
    function getNodeTransitionCost (n1 :INode, n2 :INode) :Number;

}

}
