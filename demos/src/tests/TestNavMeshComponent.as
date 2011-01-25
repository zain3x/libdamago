package tests {
import com.pblabs.engine.core.ObjectType;
import com.pblabs.engine.entity.IEntity;

import flash.display.Sprite;

import net.amago.math.geometry.Polygon;

public class TestNavMeshComponent extends Sprite
{
    public function TestNavMeshComponent ()
    {
		/*
		Goals:
		component for 'terrain'
		pathfinding that notifies upon reaching target
		AI plugin for basic pathfinding tasks
		pushbutton tasks for common pathfinding tasks
		no navmesh code should be dependent on the pushbutton code 
		
		*/
        NavMeshComponent
    }
	
	protected function createTerrainEntity (polygon :Polygon, type :ObjectType = null) :IEntity
	{
		
	}
}
}