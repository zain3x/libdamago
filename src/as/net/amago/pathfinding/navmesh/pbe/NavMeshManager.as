package net.amago.pathfinding.navmesh.pbe {
import com.threerings.util.F;

import com.pblabs.engine.core.ObjectType;
import com.pblabs.engine.entity.EntityComponent;
import com.threerings.geom.Vector2;
import com.threerings.util.ArrayUtil;
import com.threerings.util.ClassUtil;
import com.threerings.util.Map;
import com.threerings.util.Maps;

import flash.events.Event;

import net.amago.pathfinding.navmesh.PathToFollow;
import net.amago.pathfinding.navmesh.Pathfinder;

public class NavMeshManager extends EntityComponent
{
	public static const CHANGED :String = ClassUtil.tinyClassName(NavMeshManager) + "Changed";
    public static const COMPONENT_NAME :String = "navmeshPath";

    override protected function onAdd () :void
    {
        super.onAdd();
    }

    override protected function onRemove () :void
    {
        super.onRemove();
		//Remove all obstacle components refs
		_obstacles.forEach(F.adapt(removeObstacle));
		_obstacles = [];
		_objectTypeToNavMesh.clear();
    }

	
    internal function addObstacle (comp :ExclusionComponent) :void
    {
		if (ArrayUtil.contains(_obstacles, comp)) {
			return;
		}
		trace("Adding obstacle to manager");
		_obstacles.push(comp);
		comp._manager = this;
		
		_nav.addNavMeshPolygon(comp.navmeshPolygon);
		
		owner.eventDispatcher.dispatchEvent(new Event(CHANGED));
//		var mesh :NavMesh = getNaveMesh(comp);
//		mesh.addPolygon(comp.navmeshPolygon);
    }
	
	public function get pathFinder () :Pathfinder
	{
		return _nav;
		//		var mesh :NavMesh = _objectTypeToNavMesh.get(comp.obstacleType) as NavMesh;
		//		if (mesh == null) {
		//			mesh = new NavMesh();
		//			_objectTypeToNavMesh.put(comp.obstacleType, mesh);
		//		}
		//		return mesh;
	}
	
    internal function removeObstacle (comp :ExclusionComponent) :void
    {
		if (comp == null) {
			return;
		}
        ArrayUtil.removeFirst(_obstacles, comp);
		comp._manager = null;
    }
	
	public function getPath (fromX :Number, fromY :Number, toX :Number, toY :Number) :PathToFollow
	{
		var path :PathToFollow = _nav.getPath(new Vector2(fromX, fromY), new Vector2(toX, toY)); 
		owner.eventDispatcher.dispatchEvent(new Event(CHANGED));
		return path;
	}
	protected var _objectTypeToNavMesh :Map = Maps.newMapOf(ObjectType);//<ObjectType, NavMesh>
//	protected var _navMesh :NavMesh = new NavMesh();
	protected var _nav :Pathfinder = new Pathfinder();

    protected var _obstacles :Array = [];//<ObstacleComponent>
}
}
