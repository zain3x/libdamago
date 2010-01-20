package net.amago.pathfinding.navmesh.pbe {
import com.pblabs.engine.core.ObjectType;
import com.pblabs.engine.entity.EntityComponent;
import com.pblabs.engine.entity.PropertyReference;
import com.threerings.util.ClassUtil;

import flash.events.Event;

import net.amago.math.geometry.Polygon;
import net.amago.pathfinding.navmesh.NavMeshPolygonExclusion;

public class ExclusionComponent extends EntityComponent
{
	public static const CHANGED :String = ClassUtil.tinyClassName(ExclusionComponent) + "Changed";
	
	public var managerProperty :PropertyReference;
	public var obstacleTypeRef :PropertyReference;
	public var xProperty :PropertyReference;
	public var yProperty :PropertyReference;
	
	public function get obstacleType () :ObjectType
	{
		if (_obstacleType != null) {
			return _obstacleType;
		}
		if (obstacleTypeRef == null) {
			return null;
		}
		return owner.getProperty(obstacleTypeRef) as ObjectType;
	}
	
	/**
	 * Notify the manager if this changes (currently by detach/reattach to force an update).
	 */
	public function set obstacleType (val :ObjectType) :void
	{
		removeFromManager();
		_obstacleType = val;
		addToManager();
	}
	
	public function get polygon () :Polygon
	{
		return _polygon;
	}
	
	/**
	 * After setting the vertices, remove and re-add ourselves to the 
	 * manager to force an update.
	 */
	public function set vertices (val :Array) :void
	{
		removeFromManager();
		_polygon = new NavMeshPolygonExclusion(val);
		addToManager();
		owner.eventDispatcher.dispatchEvent(new Event(CHANGED));
	}
	
	override protected function onRemove() : void
	{
		super.onRemove();
		if (_manager != null) {
			_manager.removeObstacle(this);
		}
	}
	
	override protected function onReset() : void
	{
		super.onReset();
		//Look for the manager if we don't have one
		if (_manager == null && manager != null && _polygon != null) {
			manager.addObstacle(this);
		}
	}
	
	protected function addToManager () :void
	{
		if (manager != null) {
			manager.addObstacle(this);
		}	
	}
	
	protected function removeFromManager () :void
	{
		if (_manager != null) {
			_manager.removeObstacle(this);
		}
	}
	
	protected function get manager () :NavMeshManager
	{
		return owner.getProperty(managerProperty) as NavMeshManager;
	}
	
	internal function get navmeshPolygon () :NavMeshPolygonExclusion
	{
		return _polygon;
	}
	
	public function get x () :Number
	{
		return owner.getProperty(xProperty, 0);
	}
	
	public function get y () :Number
	{
		return owner.getProperty(yProperty, 0);
	}
	
	protected var _obstacleType :ObjectType;
	protected var _polygon :NavMeshPolygonExclusion;
	internal var _manager :NavMeshManager;
}
}