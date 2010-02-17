package net.amago.pathfinding.navmesh {
import com.threerings.geom.Vector2;
import net.amago.pathfinding.astar.Astar;
import net.amago.pathfinding.astar.SearchResults;
public class Pathfinder 
{
	
	public function get currentPath () :Array
	{
		return _currentPath;
	}
    public function get navMesh () :NavMesh
    {
        return _navMesh;
    }

    public function addNavMeshPolygon (poly :NavMeshPolygonExclusion) :void
    {
        _navMesh.addPolygon(poly);
    }

    public function getPath (from :Vector2, target :Vector2) :PathToFollow
    {
		//Remove previous path
		_navMesh.removeNode(_fromNode);
		_navMesh.removeNode(_toNode);
		
		//Add the to/from nodes, and connect them to the mesh
		_fromNode = _navMesh.addNode(_navMesh.createNode(from.x, from.y));
        _toNode = _navMesh.addNode(_navMesh.createNode(target.x, target.y));
		_navMesh.checkNodeForEdges(_fromNode);
		_navMesh.checkNodeForEdges(_toNode);

		//Compute the path
        var pathToFollow :PathToFollow = new PathToFollow();
        var astar :Astar = new Astar(_navMesh);
        var searchResults :SearchResults = astar.search(_fromNode, _toNode);
		
        if (!searchResults.getIsSuccess()) {
			_currentPath = null;
            return pathToFollow;
        }
		
        var path :Array = searchResults.getPath().getNodes();

        for each (var v :Vector2 in path) {
            pathToFollow.addPathPoint(v.x, v.y);
        }

		//Add curvature to the path.  This should be parametized out of this method
        pathToFollow = pathToFollow.addBezierCurvature(2, 0);
        _currentPath = path;
        return pathToFollow;
    }
    protected var _currentPath :Array;

	protected var _fromNode :NavMeshNode;
    protected var _navMesh :NavMesh = new NavMesh();
	protected var _toNode :NavMeshNode;
}
}