package net.amago.pathfinding.navmesh.pbe {
import com.pblabs.engine.core.ObjectType;
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.util.ClassUtil;

import flash.events.Event;
import flash.geom.Point;

import net.amago.pathfinding.navmesh.PathToFollow;

public class PathFindingComponent extends EntityComponent
{
	public static const CHANGED :String = ClassUtil.tinyClassName(PathFindingComponent) + "Changed";
    public static const COMPONENT_NAME :String = "navmesh";
	
	public var managerProperty :PropertyReference;
	public var xProperty :PropertyReference;
	public var yProperty :PropertyReference;
	
	public function findPathToPoint (target :Point, obstacleTypes :ObjectType = null) :PathToFollow
	{
		if (manager == null) {
			trace("manager is null");
			_path = null;
			return null;
		}
		
		_path = manager.getPath(x, y, target.x, target.y);
//		trace("path=" + _path);
		owner.eventDispatcher.dispatchEvent(new Event(CHANGED));
		return _path;
	}
	
	protected function get manager () :NavMeshManager
	{
		if (owner == null) {
			return null;
		}
		return owner.getProperty(managerProperty) as NavMeshManager;
	}
	
	protected function get x () :Number
	{
		return owner.getProperty(xProperty) as Number;
	}
	
	protected function get y () :Number
	{
		return owner.getProperty(yProperty) as Number;
	}
	
	override protected function onAdd() : void
	{
		super.onAdd();
		//Find the manager
	}
//	
//	override protected function onRemove() : void
//	{
//		super.onRemove();
//		if (_manager != null) {
//			_manager.removeObstacle(this);
//		}
//	}
	
	public function get path () :PathToFollow
	{
		return _path;
	}
	
	protected var _path :PathToFollow;
	
}
}
